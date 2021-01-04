require 'rails_helper'

describe ApplicationHelper do
  context '#present' do
    let(:claim) { create(:advocate_claim) }

    it 'returns a <Classname>Presenter instance' do
     expect(present(claim)).to be_a Claim::BaseClaimPresenter
    end

    it 'yields a <Classname>Presenter Class' do
      expect { |b| present(claim, &b) }.to yield_with_args(Claim::BaseClaimPresenter)
    end
  end

  context '#present_collection' do
    let(:claims) { create_list(:claim, 2) }

    it 'should return a collection of <Classname>Presenter instances' do
      present_collection(claims).each do |claim|
        expect(claim).to be_instance_of Claim::AdvocateClaimPresenter
      end
    end

    it 'should yield a collection of <Classname>Presenter Class instances' do
      expect { |block| present_collection(claims, &block) }.to yield_with_args([Claim::BaseClaimPresenter,Claim::BaseClaimPresenter])
    end
  end

  context '#number_with_precision_or_default' do
    it 'should return empty string if given integer zero and no precision' do
      expect(number_with_precision_or_default(0)).to eq ''
    end

    it 'should return empty string if given integer zero and precision' do
      expect(number_with_precision_or_default(0, precision: 2)).to eq ''
    end

    it 'should return empty string if given BigDecimal zero' do
      expect(number_with_precision_or_default(BigDecimal(0, 5))).to eq ''
    end

    it 'should return empty string if given Float zero' do
      expect(number_with_precision_or_default(0.0, precision: 2)).to eq ''
    end

    it 'should return 3.33 if given 3.3333 with precsion 2' do
      expect(number_with_precision_or_default(3.333, precision: 2)).to eq '3.33'
    end

    it 'should return 24.5 if given 24.5 with no precision' do
      expect(number_with_precision_or_default(24.5)).to eq '24.5'
    end

    it 'should return 4 if given 3.645 with precsion 0' do
      expect(number_with_precision_or_default(3.645, precision: 0)).to eq '4'
    end

    context 'with default specified' do
      it 'should return default value if given Float zero with precision 2' do
        expect(number_with_precision_or_default(0.0, precision: 2, default: '1')).to eq '1'
      end

      it 'should NOT return default value if given a non-zero value' do
        expect(number_with_precision_or_default(2, default: '1')).to eq '2'
      end
    end

    context '#user_requires_scheme_column?' do
      let(:admin)     { create(:external_user, :agfs_lgfs_admin) }
      let(:advocate)  { create(:external_user, :advocate) }
      let(:litigator) { create(:external_user, :litigator) }

      it 'should return true for those users that could have AGFS and LGFS claims' do
        allow(helper).to receive(:current_user).and_return(admin.user)
        expect(helper.user_requires_scheme_column?).to eql true
      end

      it 'should return false for users that only handle AGFS claims' do
        allow(helper).to receive(:current_user).and_return(advocate.user)
        expect(helper.user_requires_scheme_column?).to eql false
      end

      it 'should return true for users that only handle LGFS claims' do
        allow(helper).to receive(:current_user).and_return(litigator.user)
        expect(helper.user_requires_scheme_column?).to eql true
      end
    end
  end

  describe '#cp' do
    subject(:cp) { helper.cp(path_with_params) }

    let(:path) { 'test' }
    let(:path_with_params) { path }

    context 'when the current request path matches that passed in' do
      before { controller.request.path = path }

      it { is_expected.to eql 'current' }

      context 'when then the tab param is set' do
        before { controller.request.GET[:tab] = 'also_test' }

        context 'and matches' do
          let(:path_with_params) { 'test?tab=also_test' }

          it { is_expected.to eql 'current' }
        end

        context 'and does not match' do
          let(:path_with_params) { 'test?tab=still_not_a_test' }

          it { is_expected.to eql nil }
        end
      end
    end

    context 'when the current request path does not match the one passed in' do
      before { controller.request.path = 'not_a_test' }

      it { is_expected.to eql nil }
    end
  end
end
