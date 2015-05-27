require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:persona) }
  it { should have_many(:messages_sent).class_name('Message').with_foreign_key('sender_id') }

  it { should delegate_method(:claims).to(:persona) }
end
