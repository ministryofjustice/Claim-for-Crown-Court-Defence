require 'rails_helper'

RSpec.describe OffenceBand do
  it { should belong_to(:offence_category) }
end
