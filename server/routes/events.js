import { Router } from 'express'

const router = Router()

// GET /api/events/active - 获取进行中的活动
router.get('/active', (req, res) => {
  res.json({
    success: true,
    data: {
      active: false,
      events: []
    }
  })
})

export default router
