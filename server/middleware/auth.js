import jwt from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET || 'xiuxian_jwt_secret_2026'
const OLD_JWT_SECRET = 'xiuxian_secret_2026'

export function auth(req, res, next) {
  const header = req.headers.authorization
  if (!header) return res.status(401).json({ success: false, message: '未登录' })
  const token = header.replace('Bearer ', '')
  
  // 先尝试新secret
  try {
    const decoded = jwt.verify(token, JWT_SECRET)
    req.user = { userId: decoded.userId, walletAddress: decoded.walletAddress }
    return next()
  } catch {}
  
  // 再尝试旧secret（兼容旧token）
  try {
    const decoded = jwt.verify(token, OLD_JWT_SECRET)
    req.user = { userId: decoded.id, walletAddress: decoded.wallet }
    return next()
  } catch {}
  
  return res.status(401).json({ success: false, message: 'token无效或已过期' })
}

export { JWT_SECRET }
