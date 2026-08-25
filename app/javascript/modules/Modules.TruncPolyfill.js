String.prototype.trunc = String.prototype.trunc || function (n) { // eslint-disable-line no-extend-native
  return (this.length > n) ? this.substr(0, n - 1) + '&hellip;' : this
}
