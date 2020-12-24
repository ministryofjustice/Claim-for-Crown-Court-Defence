# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

require 'rails_helper'
require_relative 'shared_examples_for_defendant_uplifts'

RSpec.describe Fee::BaseFeeType, type: :model do
  include DatabaseHousekeeping

  class FeeTypeDouble < described_class; end

  subject(:fee_type) { FeeTypeDouble.new }

  context '#new' do
    it 'should raise BaseFeeTypeAbstractClassError' do
      expect {
        described_class.new
      }.to raise_error Fee::BaseFeeTypeAbstractClassError, 'Fee::BaseFeeType is an abstract class and cannot be instantiated'
    end
  end

  it { is_expected.to respond_to(*%i[lgfs? agfs? agfs_scheme_9? agfs_scheme_10? agfs_scheme_12?]) }
  it { expect(described_class).to respond_to(*%i[lgfs agfs agfs_scheme_9s agfs_scheme_10s agfs_scheme_12s]) }

  it_behaves_like 'roles', Fee::MiscFeeType, Fee::MiscFeeType::ROLES # using MiscFeeType because the shared examples use a factory, which rules out the use of a class double
  it_behaves_like 'defendant upliftable'

  it { should have_many(:fees) }

  it { should validate_presence_of(:description).with_message('Fee type description cannot be blank') }
  it { should validate_presence_of(:code).with_message('Fee type code cannot be blank') }
  it { should validate_uniqueness_of(:description).ignoring_case_sensitivity.with_message('Fee type description must be unique').scoped_to(:type) }

  it { should respond_to(:code) }
  it { should respond_to(:description) }

  describe '#requires_dates_attended?' do
    it 'returns false' do
      expect(build(:fixed_fee_type).requires_dates_attended?).to be false
      expect(build(:misc_fee_type).requires_dates_attended?).to be false
    end
  end

  describe '#quanity_is_decimal?' do
    it 'should return false' do
      ft = build :basic_fee_type
      expect(ft.quantity_is_decimal).to be false
    end
    it 'should return true' do
      ft = build :misc_fee_type, :spf
      expect(ft.quantity_is_decimal).to be true
    end
  end

  describe '#fee_category_name' do
    it 'returns the humanised name' do
      expect(build(:basic_fee_type).fee_category_name).to eq 'Basic Fees'
      expect(build(:fixed_fee_type).fee_category_name).to eq 'Fixed Fees'
      expect(build(:misc_fee_type).fee_category_name).to eq 'Miscellaneous Fees'
      expect(build(:graduated_fee_type).fee_category_name).to eq 'Graduated Fees'
      expect(build(:transfer_fee_type).fee_category_name).to eq 'Transfer Fee'
      expect(build(:interim_fee_type).fee_category_name).to eq 'Interim Fees'
      expect(build(:warrant_fee_type).fee_category_name).to eq 'Warrant Fee'
    end
  end

  describe '#pretty_max_amount' do
    it 'returns a prettified string of the max amount' do
      ft = FeeTypeDouble.new(max_amount: 125_367.8)
      expect(ft.pretty_max_amount).to eq '£125,368'
    end
  end

  context 'when calling specialized fee type scopes' do
    before(:all) do
      @bf1 = create :basic_fee_type, description: 'basic fee type 1'
      @bf2 = create :basic_fee_type, description: 'basic fee type 2'
      @mf1 = create :misc_fee_type, description: 'misc fee type 1'
      @mf2 = create :misc_fee_type, description: 'misc fee type 2'
      @ff1 = create :fixed_fee_type, description: 'fixed fee type 1'
      @ff2 = create :fixed_fee_type, description: 'fixed fee type 2'
      @wf1 = create :warrant_fee_type, description: 'warrant fee type 1'
      @wf2 = create :warrant_fee_type, description: 'warrant fee type 2'
      @gf1 = create :graduated_fee_type, description: 'grad fee type 1'
      @gf2 = create :graduated_fee_type, description: 'grad fee type 2'
      @if1 = create :interim_fee_type, description: 'interim fee type 1'
      @if2 = create :interim_fee_type, description: 'interim fee type 2'
      @tf1 = create :transfer_fee_type, description: 'transfer fee type 1'
    end

    after(:all) { clean_database }

    describe '#fee_class_name' do
      it 'returns the name of the corresponding fee as a string' do
        expect(@bf1.fee_class_name).to eq 'Fee::BasicFee'
        expect(@mf1.fee_class_name).to eq 'Fee::MiscFee'
        expect(@ff1.fee_class_name).to eq 'Fee::FixedFee'
        expect(@wf1.fee_class_name).to eq 'Fee::WarrantFee'
        expect(@gf1.fee_class_name).to eq 'Fee::GraduatedFee'
        expect(@if1.fee_class_name).to eq 'Fee::InterimFee'
        expect(@tf1.fee_class_name).to eq 'Fee::TransferFee'
      end
    end

    describe '.basic' do
      it 'returns all basic fee types' do
        expect(described_class.basic).to match_array([@bf1, @bf2])
      end
    end

    describe '.misc' do
      it 'returns all misc fee types' do
        expect(described_class.misc).to match_array([@mf1, @mf2])
      end
    end

    describe '.fixed' do
      it 'returns all fixed fee types' do
        expect(described_class.fixed).to match_array([@ff1, @ff2])
      end
    end

    describe '.warrant' do
      it 'returns all warrant fee types' do
        expect(described_class.warrant).to match_array([@wf1, @wf2])
      end
    end

    describe '.graduated' do
      it 'returns all graduated fee types' do
        expect(described_class.graduated).to match_array([@gf1, @gf2])
      end
    end

    describe '.interim' do
      it 'returns all interim fee types' do
        expect(described_class.interim).to match_array([@if1, @if2])
      end
    end

    describe '.transfer' do
      it 'returns all transfer fee types' do
        expect(described_class.transfer).to match_array([@tf1])
      end
    end
  end

  context 'when calling scheme role scope' do
    before do
      create(:basic_fee_type, description: 'Scheme 9, 10 and 12 roles', roles: %w[agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12])
      create(:fixed_fee_type, description: 'Scheme 10 and 12 roles', roles: %w[agfs agfs_scheme_10 agfs_scheme_12])
      create(:misc_fee_type, description: 'Scheme 12 role only', roles: %w[agfs agfs_scheme_12])
      create(:misc_fee_type, description: 'Scheme 9 role only', roles: %w[agfs agfs_scheme_9])
    end

    describe '.agfs_scheme_9s' do
      subject { described_class.agfs_scheme_9s.map(&:description) }

      it {
        is_expected.to match_array(['Scheme 9, 10 and 12 roles', 'Scheme 9 role only'])
      }
    end

    describe '.agfs_scheme_10s' do
      subject { described_class.agfs_scheme_10s.map(&:description) }

      it {
        is_expected.to match_array(['Scheme 9, 10 and 12 roles', 'Scheme 10 and 12 roles'])
      }
    end

    describe '.agfs_scheme_12s' do
      subject { described_class.agfs_scheme_12s.map(&:description) }

      it {
        is_expected.to match_array(['Scheme 9, 10 and 12 roles', 'Scheme 10 and 12 roles','Scheme 12 role only'])
      }
    end
  end
end
