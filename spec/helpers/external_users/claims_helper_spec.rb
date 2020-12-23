require 'rails_helper'

describe ExternalUsers::ClaimsHelper do
  describe '#error_class?' do
    let(:presenter) { instance_double(ErrorPresenter) }

    context 'with errors' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(kind_of(Symbol)).and_return('an error')
      end

      it 'should return the default error class if there are any errors in the provided field' do
        returned_class = error_class?(presenter, :test_field)
        expect(returned_class).to eq('dropdown_field_with_errors')
      end

      it 'should return the specified class if provided' do
        returned_class = error_class?(presenter, :test_field, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'with errors and multiple fields' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(:test_field_1).and_return(nil)
        allow(presenter).to receive(:field_level_error_for).with(:test_field_2).and_return('an error')
      end

      it 'should return the error class if there are errors in any of the provided field' do
        returned_class = error_class?(presenter, :test_field_1, :test_field_2)
        expect(returned_class).to eq('dropdown_field_with_errors')
      end

      it 'should return the specified class if provided' do
        returned_class = error_class?(presenter, :test_field_1, :test_field_2, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'without errors' do
      before do
        allow(presenter).to receive(:field_level_error_for).with(kind_of(Symbol)).and_return(nil)
      end

      it 'should return nil if there are no errors in the provided field' do
        returned_class = error_class?(presenter, :test_field)
        expect(returned_class).to be_nil
      end
    end
  end

  describe '#show_timed_retention_banner_to_user?' do
    let(:current_user) { create(:external_user, :advocate).user }
    let(:user_settings) { {} }

    before do
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'user is not an external user' do
      let(:current_user) { create(:case_worker).user }

      it 'should return false' do
        expect(helper.show_timed_retention_banner_to_user?).to be_falsey
      end
    end

    context 'user has not seen yet the promo' do
      it 'should return true' do
        expect(helper.show_timed_retention_banner_to_user?).to be_truthy
      end
    end

    context 'user has seen the promo' do
      let(:user_settings) { { timed_retention_banner_seen: '1' } }

      it 'should return false' do
        expect(helper.show_timed_retention_banner_to_user?).to be_falsey
      end
    end
  end

  describe '#show_hardship_claims_banner_to_user?' do
    let(:current_user) { create(:external_user, :advocate).user }
    let(:user_settings) { {} }

    before do
      allow(Settings).to receive(:hardship_claims_banner_enabled?).and_return(hardship_claims_banner_enabled)
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'feature flag enabled' do
      let(:hardship_claims_banner_enabled) { true }

      context 'user is not an external user' do
        let(:current_user) { create(:case_worker).user }

        it 'should return false' do
          expect(helper.show_hardship_claims_banner_to_user?).to be_falsey
        end
      end

      context 'user has not seen yet the promo' do
        it 'should return true' do
          expect(helper.show_hardship_claims_banner_to_user?).to be_truthy
        end
      end

      context 'user has seen/dismissed the banner' do
        let(:user_settings) { { hardship_claims_banner_seen: '1' } }

        it 'should return false' do
          expect(helper.show_hardship_claims_banner_to_user?).to be_falsey
        end
      end
    end

    context 'feature flag disabled' do
      let(:hardship_claims_banner_enabled) { false }

      it 'should return false regardless of the user setting' do
        expect(helper).not_to receive(:current_user)
        expect(helper.show_hardship_claims_banner_to_user?).to be_falsey
      end
    end
  end

  describe 'url_for_referrer' do
    let(:claim) { create(:advocate_claim) }

    context 'when referrer is summary' do
      let(:referrer) { :summary }

      it 'returns the url for the check your claim page' do
        expect(helper.url_for_referrer(referrer, claim)).to eq(summary_external_users_claim_path(claim))
      end
    end

    context 'when referrer is not known' do
      let(:referrer) { :not_known }

      it 'returns nil' do
        expect(helper.url_for_referrer(referrer, claim)).to be_nil
      end
    end
  end

  describe 'claim_requires_dates_attended?' do
    subject { helper.claim_requires_dates_attended?(claim) }

    context 'when claim fee_scheme is nine' do
      let(:claim) { build(:advocate_claim, case_type: case_type) }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Guilty pLea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end

    context 'when claim fee_scheme is ten' do
      let!(:scheme_10) { create(:fee_scheme, :agfs_ten) }
      let(:claim) { create(:advocate_claim, :agfs_scheme_10, case_type: case_type) }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be false }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be false }
      end

      context 'and has a case type of Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end
  end

  describe 'show_add_date_link?' do
    subject { helper.show_add_date_link?(fee) }

    context 'when claim fee_scheme is nine' do
      let(:claim) { build(:advocate_claim, case_type: case_type) }
      let(:fee) { build :basic_fee, :baf_fee, claim: claim }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Guilty pLea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be false }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end

    context 'when claim fee_scheme is ten' do
      let!(:scheme_10) { create(:fee_scheme, :agfs_ten) }
      let(:claim) { create(:advocate_claim, :agfs_scheme_10, case_type: case_type) }
      let(:fee) { build :basic_fee, :baf_fee, claim: claim }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'and has a case type of Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be false }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#build_dates_attended?' do
    subject { helper.build_dates_attended?(fee) }

    let(:claim) { create(:claim, case_type: case_type) }
    let(:fee) { build :basic_fee, :baf_fee, claim: claim }

    context 'when claim is not hardship' do
      before { allow(claim).to receive(:hardship?).and_return false }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }
        it { is_expected.to be true }
      end

      context 'and has a case type of Discontinuance' do
        let(:case_type) { build(:case_type, :discontinuance) }
        it { is_expected.to be true }
      end
    end

    context 'when claim is hardship' do
      before { allow(claim).to receive(:hardship?).and_return true }

      context 'and has a case type of Trial' do
        let(:case_type) { build(:case_type, :trial) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Retrial' do
        let(:case_type) { build(:case_type, :retrial) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Contempt' do
        let(:case_type) { build(:case_type, :contempt) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }
        it { is_expected.to be false }
      end

      context 'and has a case type of Discontinuance' do
        let(:case_type) { build(:case_type, :discontinuance) }
        it { is_expected.to be false }
      end
    end
  end
end
