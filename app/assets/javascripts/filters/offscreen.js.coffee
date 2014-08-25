jQuery.expr.filters.offscreen = (el)->
  (el.offsetLeft + el.offsetWidth) < 0 ||
  (el.offsetTop + el.offsetHeight) < 0 ||
  (el.offsetLeft > window.innerWidth ||
  el.offsetTop > window.innerHeight)
