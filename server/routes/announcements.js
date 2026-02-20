import { Router } from 'express'

const router = Router()

// GET /api/announcements - 获取公告
router.get('/', (req, res) => {
  res.json({
    success: true,
    data: []
  })
})

export default router
