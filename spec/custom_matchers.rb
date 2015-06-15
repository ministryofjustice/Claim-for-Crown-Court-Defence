require 'rspec/expectations'

RSpec::Matchers.define :contain_claims do |*expected|
  match do |actual|
    result = expected.size == actual.size
    expected.each do |e|
      unless actual.include?(e)
        result = false 
        break
      end
    end
  end
  failure_message do |actual|
    "expected that records:\n\t #{actual.inspect} \n\nwould be equal to records\n\t #{expected.inspect}"
  end  

end