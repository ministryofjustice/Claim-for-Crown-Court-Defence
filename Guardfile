guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(scss|js|html|haml))).*}) { |m| "/assets/#{m[3]}" }
end

guard :jasmine, all_on_start: false do
  watch(%r{^spec/javascripts/.*(?:_s|S)pec\.(coffee|js)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) do |m|
    "spec/javascripts/jasmine/#{ m[1] }_spec.#{ m[2] }"
  end
end

guard :rspec, cmd: "bundle exec rspec --format Fuubar --color", all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/interfaces/api/(.+)\.rb$}) { |m| "spec/api/#{m[1]}_spec.rb" }
end

guard :rubocop, all_on_start: false do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.(rubocop|rubocop_todo)\.yml$}) { |m| File.dirname(m[0]) }
end

# NOTE Current guard-cucumber version does not support the most recent cucumber
# version (> 3.X)
# guard :cucumber, all_on_start: false do
#   watch(%r{features/.+\.feature})
# end
