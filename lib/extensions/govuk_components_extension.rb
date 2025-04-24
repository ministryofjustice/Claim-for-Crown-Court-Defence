# From Rails 7.1 the `logstasher` gem causes a 'stack level too deep' error
# when an instance of `ActionView::Helpers::FormBuilder` is passed as a
# parameter to a partial. This is because the `as_json` method is called which
# results in a circular reference.
#
# See https://github.com/rails/rails/issues/51626
module Extensions
  module GovukComponentsExtension
    def as_json; end
  end
end
