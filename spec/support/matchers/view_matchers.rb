RSpec::Matchers.define :include_table_headers do |*expected|
  match do |actual|
    @results = expected.each_with_object({}) do |text, memo|
      memo[text.to_s] = actual.has_selector?('th', text: /#{Regexp.quote(text)}\s/)
    end
    @results.values.all?
  end

  description do
    'have table headers'
  end

  failure_message do |actual|
    failures = @results.reject { |_k, v| v }
    message = failures.each_with_object('Column headers not found:') do |(text, _value), msg|
      msg << "\n- #{text}"
    end
    message << "\n\nIn HTML:\n\n#{actual.native.to_html}"
  end
end
