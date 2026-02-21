import { defineStore } from 'pinia'
import { BrowserProvider } from 'ethers'

const API_BASE = '/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    wallet: localStorage.getItem('xx_wallet') || '',
    token: localStorage.getItem('xx_token') || '',
    vipLevel: 0,
    vipName: '普通',
    totalRecharge: 0,
    firstRecharge: false,
    dailySignDate: null,
    dailySignStreak: 0,
    isConnecting: false,
  }),

  getters: {
    isLoggedIn: (state) => !!state.token && !!state.wallet,
    shortWallet: (state) => state.wallet ? state.wallet.slice(0, 6) + '...' + state.wallet.slice(-4) : '',
  },

  actions: {
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
      localStorage.removeItem('xx_wallet')
      localStorage.removeItem('xx_token')
    },

    async apiGet(path) {
      const res = await fetch(`${API_BASE}${path}`, {
        headers: { 'Authorization': `Bearer ${this.token}` }
      })
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
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      return data
    },

    async saveToCloud(playerStore) {
      if (!this.isLoggedIn) return
      const gameData = playerStore.$state
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
      return data
    },

    async confirmRecharge(txHash) {
      const data = await this.apiPost('/recharge/confirm', { txHash })
      this.vipLevel = data.vipLevel
      this.totalRecharge = data.totalRecharge
      this.firstRecharge = true
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
