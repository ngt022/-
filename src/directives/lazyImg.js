const observer = typeof IntersectionObserver !== 'undefined'
  ? new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target
          if (img.dataset.src) {
            img.src = img.dataset.src
            img.removeAttribute('data-src')
            observer.unobserve(img)
          }
        }
      })
    }, { rootMargin: '200px' })
  : null

export default {
  mounted(el, binding) {
    if (!observer) { el.src = binding.value; return }
    el.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
    el.dataset.src = binding.value
    el.style.transition = 'opacity 0.3s'
    el.style.opacity = '0'
    el.onload = () => { el.style.opacity = '1' }
    observer.observe(el)
  },
  updated(el, binding) {
    if (binding.value !== binding.oldValue) {
      el.dataset.src = binding.value
      if (observer) observer.observe(el)
    }
  },
  unmounted(el) { if (observer) observer.unobserve(el) }
}
