# == Schema Information
#
# Table name: expense_types
#
#  id         :integer          not null, primary key
#  name       :string
#  roles      :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ExpenseType, type: :model do
  it_behaves_like 'roles', ExpenseType, ExpenseType::ROLES

  it { should have_many(:expenses) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  context 'ROLES' do
    it 'should have "agfs" and "lgfs"' do
      expect(Provider::ROLES).to match_array(%w( agfs lgfs ))
    end
  end
end
