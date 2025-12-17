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

RSpec.describe Fee::BaseFeeType do
  include DatabaseHousekeeping

  class FeeTypeDouble < described_class; end

  subject(:fee_type) { FeeTypeDouble.new }

  describe '#new' do
    it 'raises BaseFeeTypeAbstractClassError' do
      expect {
        described_class.new
      }.to raise_error Fee::BaseFeeTypeAbstractClassError, 'Fee::BaseFeeType is an abstract class and cannot be instantiated'
    end
  end

  it { is_expected.to respond_to(:lgfs?, :lgfs_scheme_9?, :lgfs_scheme_10?, :lgfs_scheme_11?, :agfs?, :agfs_scheme_9?, :agfs_scheme_10?, :agfs_scheme_12?, :agfs_scheme_13?, :agfs_scheme_14?, :agfs_scheme_15?, :agfs_scheme_16?) }
  it { expect(described_class).to respond_to(:lgfs, :lgfs_scheme_9s, :lgfs_scheme_10s, :lgfs_scheme_11s, :agfs, :agfs_scheme_9s, :agfs_scheme_10s, :agfs_scheme_12s, :agfs_scheme_13s, :agfs_scheme_14s, :agfs_scheme_15s, :agfs_scheme_16s) }

  it_behaves_like 'roles', Fee::MiscFeeType, Fee::MiscFeeType::ROLES # using MiscFeeType because the shared examples use a factory, which rules out the use of a class double
  it_behaves_like 'defendant upliftable'

  it { is_expected.to have_many(:fees) }

  it { is_expected.to validate_presence_of(:description).with_message('Fee type description cannot be blank') }
  it { is_expected.to validate_presence_of(:code).with_message('Fee type code cannot be blank') }
  it { is_expected.to validate_presence_of(:unique_code).with_message('Fee type unique code cannot be blank') }
  it { is_expected.to validate_uniqueness_of(:description).ignoring_case_sensitivity.with_message('Fee type description must be unique').scoped_to(:type) }

  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:description) }

  describe '#requires_dates_attended?' do
    it 'returns false' do
      expect(build(:fixed_fee_type).requires_dates_attended?).to be false
      expect(build(:misc_fee_type).requires_dates_attended?).to be false
    end
  end

  describe '#quanity_is_decimal?' do
    it 'returns false' do
      ft = build(:basic_fee_type)
      expect(ft.quantity_is_decimal).to be false
    end

    it 'returns true' do
      ft = build(:misc_fee_type, :spf)
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
      @bf1 = create(:basic_fee_type, description: 'basic fee type 1')
      @bf2 = create(:basic_fee_type, description: 'basic fee type 2')
      @mf1 = create(:misc_fee_type, description: 'misc fee type 1')
      @mf2 = create(:misc_fee_type, description: 'misc fee type 2')
      @ff1 = create(:fixed_fee_type, description: 'fixed fee type 1')
      @ff2 = create(:fixed_fee_type, description: 'fixed fee type 2')
      @wf1 = create(:warrant_fee_type, description: 'warrant fee type 1')
      @wf2 = create(:warrant_fee_type, description: 'warrant fee type 2')
      @gf1 = create(:graduated_fee_type, description: 'grad fee type 1')
      @gf2 = create(:graduated_fee_type, description: 'grad fee type 2')
      @if1 = create(:interim_fee_type, description: 'interim fee type 1')
      @if2 = create(:interim_fee_type, description: 'interim fee type 2')
      @tf1 = create(:transfer_fee_type, description: 'transfer fee type 1')
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
        expect(described_class.basic).to contain_exactly(@bf1, @bf2)
      end
    end

    describe '.misc' do
      it 'returns all misc fee types' do
        expect(described_class.misc).to contain_exactly(@mf1, @mf2)
      end
    end

    describe '.fixed' do
      it 'returns all fixed fee types' do
        expect(described_class.fixed).to contain_exactly(@ff1, @ff2)
      end
    end

    describe '.warrant' do
      it 'returns all warrant fee types' do
        expect(described_class.warrant).to contain_exactly(@wf1, @wf2)
      end
    end

    describe '.graduated' do
      it 'returns all graduated fee types' do
        expect(described_class.graduated).to contain_exactly(@gf1, @gf2)
      end
    end

    describe '.interim' do
      it 'returns all interim fee types' do
        expect(described_class.interim).to contain_exactly(@if1, @if2)
      end
    end

    describe '.transfer' do
      it 'returns all transfer fee types' do
        expect(described_class.transfer).to contain_exactly(@tf1)
      end
    end
  end

  context 'when calling scheme role scope' do
    before do
      create(:basic_fee_type, description: 'AGFS Scheme 9, 10, 12 and 13 roles', roles: %w[agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12 agfs_scheme_13])
      create(:basic_fee_type, description: 'AGFS Scheme 9, 10 and 12 roles', roles: %w[agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12])
      create(:fixed_fee_type, description: 'AGFS Scheme 10, 12 and 13 roles', roles: %w[agfs agfs_scheme_10 agfs_scheme_12 agfs_scheme_13])
      create(:fixed_fee_type, description: 'AGFS Scheme 12 and 13 roles', roles: %w[agfs agfs_scheme_12 agfs_scheme_13])
      create(:fixed_fee_type, description: 'AGFS Scheme 10 and 12 roles', roles: %w[agfs agfs_scheme_10 agfs_scheme_12])
      create(:misc_fee_type, description: 'AGFS Scheme 12 role only', roles: %w[agfs agfs_scheme_12])
      create(:misc_fee_type, description: 'AGFS Scheme 9 role only', roles: %w[agfs agfs_scheme_9])
      create(:basic_fee_type, description: 'LGFS Scheme 9, 10 and 11 roles', roles: %w[lgfs lgfs_scheme_9 lgfs_scheme_10 lgfs_scheme_11])
      create(:fixed_fee_type, description: 'LGFS Scheme 9 role only', roles: %w[lgfs lgfs_scheme_9])
      create(:misc_fee_type, description: 'LGFS Scheme 10 role only', roles: %w[lgfs lgfs_scheme_10])
      create(:misc_fee_type, description: 'LGFS Scheme 11 role only', roles: %w[lgfs lgfs_scheme_11])
    end

    describe '.agfs_scheme_9s' do
      subject { described_class.agfs_scheme_9s.map(&:description) }

      it { is_expected.to contain_exactly('AGFS Scheme 9, 10, 12 and 13 roles', 'AGFS Scheme 9, 10 and 12 roles', 'AGFS Scheme 9 role only') }
    end

    describe '.agfs_scheme_10s' do
      subject { described_class.agfs_scheme_10s.map(&:description) }

      it { is_expected.to contain_exactly('AGFS Scheme 9, 10, 12 and 13 roles', 'AGFS Scheme 9, 10 and 12 roles', 'AGFS Scheme 10, 12 and 13 roles', 'AGFS Scheme 10 and 12 roles') }
    end

    describe '.agfs_scheme_12s' do
      subject { described_class.agfs_scheme_12s.map(&:description) }

      it { is_expected.to contain_exactly('AGFS Scheme 9, 10, 12 and 13 roles', 'AGFS Scheme 9, 10 and 12 roles', 'AGFS Scheme 10, 12 and 13 roles', 'AGFS Scheme 12 and 13 roles', 'AGFS Scheme 10 and 12 roles', 'AGFS Scheme 12 role only') }
    end

    describe '.agfs_scheme_13s' do
      subject { described_class.agfs_scheme_13s.map(&:description) }

      it do
        is_expected.to contain_exactly('AGFS Scheme 9, 10, 12 and 13 roles', 'AGFS Scheme 10, 12 and 13 roles', 'AGFS Scheme 12 and 13 roles')
      end
    end

    describe '.lgfs_scheme_9s' do
      subject { described_class.lgfs_scheme_9s.map(&:description) }

      it { is_expected.to contain_exactly('LGFS Scheme 9, 10 and 11 roles', 'LGFS Scheme 9 role only') }
    end

    describe '.lgfs_scheme_10s' do
      subject { described_class.lgfs_scheme_10s.map(&:description) }

      it { is_expected.to contain_exactly('LGFS Scheme 9, 10 and 11 roles', 'LGFS Scheme 10 role only') }
    end

    describe '.lgfs_scheme_11s' do
      subject { described_class.lgfs_scheme_11s.map(&:description) }

      it { is_expected.to contain_exactly('LGFS Scheme 9, 10 and 11 roles', 'LGFS Scheme 11 role only') }
    end
  end
end
