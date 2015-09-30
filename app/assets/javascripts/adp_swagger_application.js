//
// to provide grape swagger rails use of certain rails methods,
// particulalry link_to with methid: delete, we need
// swagger to have jquery_ujs. However, since grape swagger rails
// already includes jquery and does not require other application
// js, we do not wan tto include apd's application.js here
//
//= require jquery_ujs