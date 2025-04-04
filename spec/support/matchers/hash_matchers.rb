require 'rspec/expectations'
require 'hashdiff'

RSpec::Matchers.define :match_hash do |expected|
  match do |actual|
    @diff = Hashdiff.diff(actual, expected)
    @diff.empty?
  end

  description do
    'match expected hash'
  end

  failure_message do
    msg = "expected hashes to match\n"
    msg += "Diff: (see Hashdiff - https://github.com/liufengyun/hashdiff):\n"
    msg += format_diff(@diff)
    msg
  end

  failure_message_when_negated do
    'expected hashes not to match'
  end

  def format_diff(diff)
    diff_array = diff.each_with_object([]) do |el, memo|
      if el.is_a? Array
        memo << '--------------------'
        memo << format_diff(el)
      else
        memo << "\"#{el}\"".prepend("-\s")
      end
    end

    diff_array.join("\n")
  end
end
