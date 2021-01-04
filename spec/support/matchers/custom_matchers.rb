require 'rspec/expectations'

# Given a claim, returns true if specified attributes on claim
# plus derived totals match the values specified.
# e.g.
# expect(claim).to have_totals(fees_total: 0.0, fees_vat: 0.0, disbursements_total: 0.0, disbursements_vat: 0.0, expenses_total: 0.0, expenses_vat: 0.0)
#
RSpec::Matchers.define :have_totals do |expected|
  match do |actual|
    @errors = expected.keys.each_with_object({}) do |key, errors|
      errors[key] = [expected[key], actual.send(key)] if !actual.send(key).to_d.eql?(expected[key].to_d)
    end
    expected_total = BigDecimal(expected[:fees_total] + expected[:disbursements_total] + expected[:expenses_total], 8)
    expected_vat_amount = BigDecimal(expected[:fees_vat] + expected[:disbursements_vat] + expected[:expenses_vat], 8)
    @errors[:total] = [expected_total, actual.total] if !actual.total.eql?(expected_total)
    @errors[:vat_amount] = [expected_vat_amount, actual.vat_amount] if !actual.vat_amount.eql?(expected_vat_amount)
    @errors.empty?
  end

  description do
    'have valid totals'
  end

  failure_message do |actual|
    @errors.each_with_object('Invalid totals:') do |(k, v), msg|
      msg << "\n- #{k}: expected #{v[0]}, got #{v[1]}"
    end
  end
end
