# From Rails 7.1 the `logstasher` gem causes a 'stack level too deep' error
# when an instance of `ActionView::Helpers::FormBuilder` is passed as a
# parameter to a partial. This is because the `as_json` method is called and
# the `template` attribute results in a circular reference.
#
# See https://github.com/rails/rails/issues/51626
module Extensions
  module FormBuilderExtension
    def as_json(options = {})
      amended_options = options.tap { |o| o[:except] = options[:except].to_a << 'template' }

      super(amended_options)
    end
  end
end
