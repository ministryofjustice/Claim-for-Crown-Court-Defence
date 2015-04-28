require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:persona) }
end
