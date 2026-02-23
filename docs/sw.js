const CACHE_NAME = 'huozhiwenming-v20260223113617'
const STATIC_ASSETS = [
  './',
  './index.html',
  './manifest.json'
]

// 安装：缓存核心资源
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  )
  self.skipWaiting()
})

// 激活：清理旧缓存
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  )
  self.clients.claim()
})

// 请求拦截：网络优先，失败用缓存
self.addEventListener('fetch', e => {
  const url = new URL(e.request.url)
  
  // API 和 WS 请求不缓存
  if (url.pathname.startsWith('/api/') || url.pathname.startsWith('/ws')) return
  
  // 图片：缓存优先
  if (/\.(png|webp|jpg|jpeg|gif|svg|ico)$/.test(url.pathname)) {
    e.respondWith(
      caches.match(e.request).then(cached => {
        if (cached) return cached
        return fetch(e.request).then(resp => {
          if (resp.ok) {
            const clone = resp.clone()
            caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone))
          }
          return resp
        }).catch(() => cached)
      })
    )
    return
  }
  
  // JS/CSS：纯网络，不缓存（文件名自带hash，浏览器缓存即可）
  if (/\.(js|css)$/.test(url.pathname)) return
  
  // HTML：网络优先
  e.respondWith(
    fetch(e.request).catch(() => caches.match('./index.html'))
  )
})
