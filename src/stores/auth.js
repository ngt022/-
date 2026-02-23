import { defineStore } from 'pinia'
import { BrowserProvider } from 'ethers'

const API_BASE = '/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    wallet: localStorage.getItem('xx_wallet') || '',
    token: localStorage.getItem('xx_token') || '',
    vipLevel: parseInt(localStorage.getItem('xx_vipLevel')) || 0,
    vipName: localStorage.getItem('xx_vipName') || '普通',
    totalRecharge: parseFloat(localStorage.getItem('xx_totalRecharge')) || 0,
    firstRecharge: localStorage.getItem('xx_firstRecharge') === 'true',
    dailySignDate: localStorage.getItem('xx_dailySignDate') || null,
    dailySignStreak: parseInt(localStorage.getItem('xx_dailySignStreak')) || 0,
    isConnecting: false,
  }),

  getters: {
    isLoggedIn: (state) => !!state.token && !!state.wallet,
    shortWallet: (state) => state.wallet ? state.wallet.slice(0, 6) + '...' + state.wallet.slice(-4) : '',
  },

  actions: {
    syncToStorage() {
      localStorage.setItem('xx_vipLevel', this.vipLevel)
      localStorage.setItem('xx_vipName', this.vipName)
      localStorage.setItem('xx_totalRecharge', this.totalRecharge)
      localStorage.setItem('xx_firstRecharge', this.firstRecharge)
      localStorage.setItem('xx_dailySignDate', this.dailySignDate || '')
      localStorage.setItem('xx_dailySignStreak', this.dailySignStreak)
    },
    async connectWallet() {
      if (!window.ethereum) {
        throw new Error('请安装 MetaMask 钱包')
      }
      this.isConnecting = true
      try {
        const provider = new BrowserProvider(window.ethereum)
        const accounts = await provider.send('eth_requestAccounts', [])
        const wallet = accounts[0]
        const signer = await provider.getSigner()
        const message = `火之文明登录\n钱包: ${wallet}\n时间: ${Date.now()}`
        const signature = await signer.signMessage(message)

        const res = await fetch(`${API_BASE}/auth/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ wallet, signature, message })
        })
        const data = await res.json()
        if (!res.ok) throw new Error(data.error || '登录失败')

        this.wallet = wallet
        this.token = data.token
        this.vipLevel = data.player.vipLevel
        this.totalRecharge = data.player.totalRecharge
        this.firstRecharge = data.player.firstRecharge
        this.dailySignDate = data.player.dailySignDate
        this.dailySignStreak = data.player.dailySignStreak
        this.syncToStorage()

        localStorage.setItem('xx_wallet', wallet)
        localStorage.setItem('xx_token', data.token)

        return data.player
      } finally {
        this.isConnecting = false
      }
    },

    logout() {
      this.wallet = ''
      this.token = ''
      this.vipLevel = 0
      this.totalRecharge = 0
      this.syncToStorage()
      localStorage.removeItem('xx_wallet')
      localStorage.removeItem('xx_token')
    },

    async apiGet(path) {
      const res = await fetch(`${API_BASE}${path}`, {
        headers: { 'Authorization': `Bearer ${this.token}` }
      })
      if (res.status === 401) { this.logout(); throw new Error('登录已过期，请重新连接钱包') }
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      return data
    },

    async apiPost(path, body) {
      const res = await fetch(`${API_BASE}${path}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.token}` },
        body: JSON.stringify(body)
      })
      if (res.status === 401) { this.logout(); throw new Error('登录已过期，请重新连接钱包') }
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      return data
    },

    async saveToCloud(playerStore) {
      if (!this.isLoggedIn) return
      // 排除后端权威字段，防止前端初始值覆盖DB
      const gameData = { ...playerStore.$state }
      delete gameData.spirit
      delete gameData.cultivation
      delete gameData.level
      delete gameData.realm
      delete gameData.maxCultivation
      delete gameData.maxSpirit
      delete gameData.spiritRegenRate
      delete gameData.cultivationCost
      delete gameData.cultivationGain
      delete gameData.lastTickTime
      delete gameData._spiritRegenTimer
      delete gameData._autoCultTimer
      delete gameData._syncTimer
      const result = await this.apiPost('/game/save', {
        gameData,
        combatPower: (typeof playerStore.getCombatPower === 'function' ? playerStore.getCombatPower() : 0),
        level: playerStore.level,
        realm: playerStore.realm,
        name: playerStore.name
      })
      // Sync server-managed fields back to frontend
      if (result && result.ok) {
        if (result.spiritStones !== undefined) playerStore.spiritStones = result.spiritStones
        if (result.items !== undefined) playerStore.items = result.items
      }
    },

    async loadFromCloud() {
      if (!this.isLoggedIn) return null
      const data = await this.apiGet('/game/load')
      return data.player
    },

    async dailySign() {
      const data = await this.apiPost('/sign/daily', {})
      this.dailySignDate = new Date().toISOString().split('T')[0]
      this.dailySignStreak = data.streak
      this.syncToStorage()
      return data
    },

    async confirmRecharge(txHash) {
      const data = await this.apiPost('/recharge/confirm', { txHash })
      this.vipLevel = data.vipLevel
      this.totalRecharge = data.totalRecharge
      this.firstRecharge = true
      this.syncToStorage()
      return data
    },

    async getVipInfo() {
      return await this.apiGet('/vip/info')
    },

    async getLeaderboard(type) {
      const res = await fetch(`${API_BASE}/leaderboard/${type}`)
      return await res.json()
    },

    async getRechargeHistory() {
      return await this.apiGet('/recharge/history')
    }
  }
})
