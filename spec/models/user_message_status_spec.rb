require 'rails_helper'

RSpec.describe UserMessageStatus, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:message) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:message) }
end
