// 纯 Web Audio API 合成音效，零依赖
let audioCtx = null
let _muted = localStorage.getItem("xx_sfx_muted") === "1"

const sfxMute = {
  get muted() { return _muted },
  set muted(v) { _muted = v; localStorage.setItem("xx_sfx_muted", v ? "1" : "0") }
}

const getCtx = () => {
  if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)()
  if (audioCtx.state === 'suspended') audioCtx.resume()
  return audioCtx
}

const playTone = (freq, duration, type = 'sine', volume = 0.3, decay = true) => {
  if (_muted) return
  try {
    const ctx = getCtx()
    const osc = ctx.createOscillator()
    const gain = ctx.createGain()
    osc.type = type
    osc.frequency.value = freq
    gain.gain.value = volume
    if (decay) gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration)
    osc.connect(gain)
    gain.connect(ctx.destination)
    osc.start(ctx.currentTime)
    osc.stop(ctx.currentTime + duration)
  } catch {}
}

const playNoise = (duration, volume = 0.1) => {
  if (_muted) return
  try {
    const ctx = getCtx()
    const bufferSize = ctx.sampleRate * duration
    const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate)
    const data = buffer.getChannelData(0)
    for (let i = 0; i < bufferSize; i++) data[i] = Math.random() * 2 - 1
    const source = ctx.createBufferSource()
    source.buffer = buffer
    const gain = ctx.createGain()
    gain.gain.value = volume
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration)
    source.connect(gain)
    gain.connect(ctx.destination)
    source.start()
  } catch {}
}

// === 音效库 ===

export const sfx = {
  // 攻击命中
  hit() {
    playNoise(0.1, 0.15)
    playTone(200, 0.1, 'square', 0.15)
  },

  // 暴击
  crit() {
    playTone(600, 0.08, 'square', 0.2)
    setTimeout(() => playTone(800, 0.15, 'sawtooth', 0.2), 50)
    playNoise(0.15, 0.2)
  },

  // 连击
  combo() {
    playTone(400, 0.06, 'square', 0.15)
    setTimeout(() => playTone(500, 0.06, 'square', 0.15), 80)
    setTimeout(() => playTone(600, 0.1, 'square', 0.15), 160)
  },

  // 闪避
  dodge() {
    playTone(1200, 0.15, 'sine', 0.1)
    setTimeout(() => playTone(800, 0.1, 'sine', 0.08), 100)
  },

  // 升级/突破
  levelUp() {
    const notes = [523, 659, 784, 1047]
    notes.forEach((freq, i) => {
      setTimeout(() => playTone(freq, 0.3, 'sine', 0.2), i * 120)
    })
  },

  // 抽卡翻牌
  cardFlip() {
    playTone(800, 0.08, 'sine', 0.12)
    setTimeout(() => playTone(1000, 0.06, 'sine', 0.1), 60)
  },

  // 抽到好东西（紫色以上）
  cardRare() {
    playTone(523, 0.15, 'sine', 0.2)
    setTimeout(() => playTone(659, 0.15, 'sine', 0.2), 120)
    setTimeout(() => playTone(784, 0.2, 'sine', 0.25), 240)
    setTimeout(() => playTone(1047, 0.4, 'sine', 0.2), 360)
  },

  // 获得物品
  itemGet() {
    playTone(880, 0.1, 'sine', 0.15)
    setTimeout(() => playTone(1100, 0.15, 'sine', 0.12), 80)
  },

  // 按钮点击
  click() {
    playTone(600, 0.05, 'sine', 0.08)
  },

  // 购买成功
  purchase() {
    playTone(500, 0.1, 'sine', 0.15)
    setTimeout(() => playTone(700, 0.1, 'sine', 0.15), 100)
    setTimeout(() => playTone(900, 0.15, 'sine', 0.12), 200)
  },

  // 错误/失败
  error() {
    playTone(200, 0.2, 'square', 0.15)
    setTimeout(() => playTone(150, 0.3, 'square', 0.12), 150)
  },

  // 胜利
  victory() {
    const notes = [523, 659, 784, 659, 784, 1047]
    notes.forEach((freq, i) => {
      setTimeout(() => playTone(freq, 0.2, 'sine', 0.2), i * 150)
    })
  },

  // 失败
  defeat() {
    const notes = [400, 350, 300, 200]
    notes.forEach((freq, i) => {
      setTimeout(() => playTone(freq, 0.3, 'sine', 0.15), i * 200)
    })
  }
}

export { sfxMute }
export default sfx
