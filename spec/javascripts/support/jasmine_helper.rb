#Use this file to set/override Jasmine configuration options
#You can remove it if you don't need it.
#This file is loaded *after* jasmine.yml is interpreted.
#
#Example: using a different boot file.
#Jasmine.configure do |config|
#   config.boot_dir = '/absolute/path/to/boot_dir'
#   config.boot_files = lambda { ['/absolute/path/to/boot_dir/file.js'] }
#end
#
#Example: prevent PhantomJS auto install, uses PhantomJS already on your path.
# NOTE: travis has phantomjs pre-installed and on path so auto-install
#       not needed (and can intermittently fail with travis success
#       if install site not available)
Jasmine.configure do |config|
  config.prevent_phantom_js_auto_install = true
end
