RSpec::Matchers.define :include_table_headers do |*expected|
  match do |actual|
    @results = expected.each_with_object({}) do |text, memo|
      memo["#{text}"] = actual.has_selector?('th', text: /#{Regexp.quote(text)}\s/)
    end
    @results.values.all?
  end

  description do
    'have table headers'
  end

  failure_message do |actual|
    failures = @results.select { |k,v| !v }
    msg = failures.each_with_object('Column headers not found:') do |(text, _value), msg|
      msg << "\n- #{text}"
    end
    msg << "\n\nIn HTML:\n\n#{actual.native.to_html}"
  end
end
