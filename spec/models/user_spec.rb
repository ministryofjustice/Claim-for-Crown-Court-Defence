require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:persona) }

  it { should delegate_method(:claims).to(:persona) }
end
