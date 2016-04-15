guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(scss|js|html|haml))).*}) { |m| "/assets/#{m[3]}" }
end


# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :jasmine do
  watch(%r{^spec/javascripts/.*(?:_s|S)pec\.(coffee|js)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) do |m|
    "spec/javascripts/jasmine/#{ m[1] }_spec.#{ m[2] }"
  end
end