let _supportsWebP = null

function supportsWebP() {
  if (_supportsWebP !== null) return _supportsWebP
  try {
    const canvas = document.createElement('canvas')
    canvas.width = 1
    canvas.height = 1
    _supportsWebP = canvas.toDataURL('image/webp').indexOf('data:image/webp') === 0
  } catch {
    _supportsWebP = false
  }
  return _supportsWebP
}

export function img(src) {
  if (!src || typeof src !== 'string') return src
  if (supportsWebP() && src.endsWith('.png')) {
    return src.replace(/\.png$/, '.webp')
  }
  return src
}

export default img
