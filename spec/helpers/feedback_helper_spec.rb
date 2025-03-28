require 'rails_helper'

describe FeedbackHelper do
  describe '#referrer_is_claim?' do
    %w[claims /claims claims/ /claims/].each do |path|
      it "is truthy for path containing `#{path}`" do
        expect(helper.referrer_is_claim?(path)).to be_truthy
      end
    end

    it 'is falsey for path not containing `claims` string' do
      expect(helper.referrer_is_claim?('/claim_intention')).to be_falsey
    end

    it 'is falsey if the referrer is nil' do
      expect(helper.referrer_is_claim?(nil)).to be_falsey
    end
  end

  describe '#cannot_identify_user?' do
    subject { helper.cannot_identify_user? }

    before { allow(helper).to receive(:current_user).and_return(defined_user) }

    context 'when user is not logged in' do
      let(:defined_user) { nil }
      let(:params) { { user_id: nil } }

      it { is_expected.to be_truthy }
    end

    context 'when external user is logged in' do
      let(:defined_user) { create(:external_user, :advocate) }

      it { is_expected.to be_falsey }
    end
  end
end
