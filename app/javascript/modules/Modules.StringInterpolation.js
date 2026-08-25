if (!String.prototype.supplant) {
  String.prototype.supplant = function (o) { // eslint-disable-line
    return this.replace(
      /\{([^{}]*)\}/g,
      function (a, b) {
        const r = o[b]
        return typeof r === 'string' || typeof r === 'number' ? r : a
      }
    )
  }
}
