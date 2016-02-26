require 'rails_helper'

describe CaseType do
  it_behaves_like 'roles', CaseType, CaseType::ROLES

  context 'parents and children' do
    before(:all) do
      @parent_1 = create :case_type, :contempt
      @parent_2 = create :case_type, :hsts
      @child_1 = create :child_case_type, :asbo
      @child_2 = create :child_case_type, :s74
    end

    after(:all) do
      CaseType.delete_all
    end

    describe '.parents' do
      it 'does not return child records' do
        expect(CaseType.top_levels).to eq([@parent_1, @parent_2])   
      end
    end

    describe '#children' do
      it 'returns all the children' do
        expect(@parent_2.children).to eq( [ @child_2, @child_1 ])
      end

      it 'returns an empty array for records that dont have children' do
        expect(@parent_1.children).to eq( [] )
      end
    end

    describe '#parent' do
      it 'returns the parent' do
        expect(@child_1.parent).to eq @parent_2
      end
    end
  end

end