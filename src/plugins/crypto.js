// 火之文明 - 数据加密模块
import CryptoJS from 'crypto-js'

const CURRENT_KEY = 'huozhiwenming-2026'
const LEGACY_KEY = 'vue-idle-xiuxian'

// 数据加密（使用新 key）
export const encryptData = data => {
  try {
    const jsonStr = JSON.stringify(data)
    return CryptoJS.AES.encrypt(jsonStr, CURRENT_KEY).toString()
  } catch (error) {
    console.error('数据加密失败:', error)
    return null
  }
}

// 数据解密（先试新 key，失败 fallback 旧 key，实现无缝迁移）
export const decryptData = encryptedData => {
  // 尝试新 key
  try {
    const bytes = CryptoJS.AES.decrypt(encryptedData, CURRENT_KEY)
    const str = bytes.toString(CryptoJS.enc.Utf8)
    if (str) return JSON.parse(str)
  } catch {}
  // fallback 旧 key
  try {
    const bytes = CryptoJS.AES.decrypt(encryptedData, LEGACY_KEY)
    const str = bytes.toString(CryptoJS.enc.Utf8)
    if (str) return JSON.parse(str)
  } catch (error) {
    console.error('数据解密失败:', error)
  }
  return null
}

// 数据校验
export const validateData = data => {
  const requiredFields = ['name', 'level', 'realm', 'cultivation', 'maxCultivation', 'spirit', 'baseAttributes']

  for (const field of requiredFields) {
    if (!(field in data)) {
      console.error(`数据验证失败: 缺少必要字段 ${field}`)
      return false
    }
  }

  if (data.level < 1 || data.cultivation < 0 || data.spirit < 0) {
    console.error('数据验证失败: 数值异常')
    return false
  }

  return true
}
