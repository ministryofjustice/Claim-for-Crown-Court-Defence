require 'rails_helper'

RSpec.describe ClaimStateTransition, type: :model do
  it { should belong_to :claim }
end
