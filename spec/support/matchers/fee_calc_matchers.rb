# include_fee_calc_error
# e.g. subject(:response) { described_class.new(claim, params).call }
# e.g. is_expected.to include_fee_calc_error(/Not found/i)
#
RSpec::Matchers.define :include_fee_calc_error do |expected = nil|
  match do |actual|
    [
      actual.errors.present?,
      !expected || actual.errors&.join&.match?(expected)
    ].all?
  end

  description do
    return "include fee calculator error matching #{expected}" if expected
    'include fee calculator error'
  end

  failure_message do |actual|
    return "expected \"#{actual.errors&.join || 'nil'}\" to match #{expected}" if expected
    "expected #{actual.errors || 'nil'} to not be empty"
  end
end
