require 'rails_helper'

describe FeedbackHelper do

  describe '#referrer_is_claim?' do
    %w(claims /claims claims/ /claims/).each do |path|
      it "should be truthy for path containing `#{path}`" do
        expect(helper.referrer_is_claim?(path)).to be_truthy
      end
    end

    it 'should be falsey for path not containing `claims` string' do
      expect(helper.referrer_is_claim?('/claim_intention')).to be_falsey
    end
  end

end
