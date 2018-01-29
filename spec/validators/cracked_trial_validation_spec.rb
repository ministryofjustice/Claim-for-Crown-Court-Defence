require 'rails_helper'

RSpec.describe 'new validation rules around cracked trials', type: :validator do

  context 'cracked (re)trials' do
    subject { cracked_trial_claim.valid? }

    let(:cracked_trial_type)    { FactoryBot.build :case_type, :requires_cracked_dates, name: 'Cracked trial' }
    let(:cracked_trial_claim)   { FactoryBot.create :claim,
                                                     case_type: cracked_trial_type,
                                                     trial_fixed_notice_at: trial_fixed_notice_at,
                                                     trial_fixed_at: trial_fixed_at,
                                                     trial_cracked_at: trial_cracked_at
                                }
    let(:trial_fixed_notice_at) { 84.days.ago }
    let(:trial_cracked_at)      { 56.days.ago }
    let(:trial_fixed_at)        { 28.days.ago }

    before { cracked_trial_claim.force_validation = true }

    it { is_expected.to be true }

    describe 'validate when trial_fixed_notice_at' do
      # trial_fixed_notice_at < trial_cracked_at
      # trial_fixed_notice_at < trial_fixed_at

      context '< trial_cracked_at and < trial_fixed_at' do
        it { is_expected.to be true }
      end

      context '= trial_fixed_at' do
        let(:trial_fixed_notice_at) { 28.days.ago }

        it { is_expected.to be false }
      end

      context '> trial_fixed_at' do
        let(:trial_fixed_notice_at) { 42.days.ago }

        it { is_expected.to be false }
      end

      context '= trial_cracked_at' do
        let(:trial_fixed_notice_at) { 56.days.ago }

        it { is_expected.to be false }
      end

      context '> trial_cracked_at' do
        let(:trial_fixed_notice_at) { 14.days.ago }

        it { is_expected.to be false }
      end

      context 'when all dates are the same' do
        let(:trial_fixed_notice_at) { 28.days.ago }
        let(:trial_cracked_at)      { 28.days.ago }

        it { is_expected.to be false }
      end
    end

    describe 'validate trial_fixed_at' do
      # trial_fixed_at > trial_fixed_notice_at

      context '> trial_fixed_notice_at' do
        it { is_expected.to be true }
      end
    end

    describe 'validate trial_cracked_at' do
      # trial_cracked_at > trial_fixed_notice_at

      context '> trial_fixed_notice_at' do
        it { is_expected.to be true }
      end

      context '< trial_fixed_notice_at' do
        let(:trial_cracked_at) { 91.days.ago }

        it { is_expected.to be false }
      end
    end
  end
end
