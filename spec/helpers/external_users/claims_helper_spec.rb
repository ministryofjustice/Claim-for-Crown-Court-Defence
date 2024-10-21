require 'rails_helper'

describe ExternalUsers::ClaimsHelper do
  describe '#error_class' do
    let(:presenter) { instance_double(ErrorMessage::Presenter) }

    context 'with errors' do
      before do
        allow(presenter).to receive(:field_errors_for).with(kind_of(Symbol)).and_return('an error')
      end

      it 'returns the default error class if there are any errors in the provided field' do
        returned_class = error_class(presenter, :test_field)
        expect(returned_class).to eq('dropdown_field_with_errors')
      end

      it 'returns the specified class if provided' do
        returned_class = error_class(presenter, :test_field, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'with errors and multiple fields' do
      before do
        allow(presenter).to receive(:field_errors_for).with(:test_field_1).and_return(nil)
        allow(presenter).to receive(:field_errors_for).with(:test_field_2).and_return('an error')
      end

      it 'returns the error class if there are errors in any of the provided field' do
        returned_class = error_class(presenter, :test_field_1, :test_field_2)
        expect(returned_class).to eq('dropdown_field_with_errors')
      end

      it 'returns the specified class if provided' do
        returned_class = error_class(presenter, :test_field_1, :test_field_2, name: 'custom-error')
        expect(returned_class).to eq('custom-error')
      end
    end

    context 'without errors' do
      before do
        allow(presenter).to receive(:field_errors_for).with(kind_of(Symbol)).and_return(nil)
      end

      it 'returns nil if there are no errors in the provided field' do
        returned_class = error_class(presenter, :test_field)
        expect(returned_class).to be_nil
      end
    end
  end

  describe '#show_timed_retention_banner_to_user?' do
    subject { helper.show_timed_retention_banner_to_user? }

    let(:current_user) { create(:external_user, :advocate).user }
    let(:user_settings) { {} }

    before do
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'when the user is not an external user' do
      let(:current_user) { create(:case_worker).user }

      it { is_expected.to be_falsey }
    end

    context 'when the user has not seen yet the promo' do
      it { is_expected.to be_truthy }
    end

    context 'when the user has seen the promo' do
      let(:user_settings) { { timed_retention_banner_seen: '1' } }

      it { is_expected.to be_falsey }
    end
  end

  describe '#show_hardship_claims_banner_to_user?' do
    subject { helper.show_hardship_claims_banner_to_user? }

    let(:current_user) { create(:external_user, :advocate).user }
    let(:user_settings) { {} }

    before do
      allow(Settings).to receive(:hardship_claims_banner_enabled?).and_return(hardship_claims_banner_enabled)
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'when the feature flag is enabled' do
      let(:hardship_claims_banner_enabled) { true }

      context 'when the user is not an external user' do
        let(:current_user) { create(:case_worker).user }

        it { is_expected.to be_falsey }
      end

      context 'when the user has not seen yet the promo' do
        it { is_expected.to be_truthy }
      end

      context 'when the user has seen/dismissed the banner' do
        let(:user_settings) { { hardship_claims_banner_seen: '1' } }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the feature flag is disabled' do
      let(:hardship_claims_banner_enabled) { false }

      context 'when the user is not an external user' do
        let(:current_user) { create(:case_worker).user }

        it { is_expected.to be_falsey }
      end

      context 'when the user has not seen yet the promo' do
        it { is_expected.to be_falsey }
      end

      context 'when the user has seen/dismissed the banner' do
        let(:user_settings) { { hardship_claims_banner_seen: '1' } }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#show_clair_contingency_banner_to_user?' do
    subject { helper.show_clair_contingency_banner_to_user? }

    let(:current_user) { create(:external_user, :advocate).user }
    let(:user_settings) { {} }

    before do
      allow(Settings).to receive(:clair_contingency_banner_enabled?).and_return(clair_contingency_banner_enabled)
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'when the feature flag is enabled' do
      let(:clair_contingency_banner_enabled) { true }

      context 'when the user is not an external user' do
        let(:current_user) { create(:case_worker).user }

        it { is_expected.to be_falsey }
      end

      context 'when the user has not seen yet the banner' do
        it { is_expected.to be_truthy }
      end

      context 'when the user has seen/dismissed the banner' do
        let(:user_settings) { { clair_contingency_banner_seen: '1' } }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the feature flag is disabled' do
      let(:clair_contingency_banner_enabled) { false }

      context 'when the user is not an external user' do
        let(:current_user) { create(:case_worker).user }

        it { is_expected.to be_falsey }
      end

      context 'when the user has not seen yet the banner' do
        it { is_expected.to be_falsey }
      end

      context 'when the user has seen/dismissed the banner' do
        let(:user_settings) { { clair_contingency_banner_seen: '1' } }

        it { is_expected.to be_falsey }
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
      let(:claim) { build(:advocate_claim, case_type:) }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Guilty pLea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be true }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end

    context 'when claim fee_scheme is ten' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10, case_type:) }

      before { create(:fee_scheme, :agfs_ten) }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be true }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end
  end

  describe 'show_add_date_link?' do
    subject { helper.show_add_date_link?(fee) }

    context 'when claim fee_scheme is nine' do
      let(:claim) { build(:advocate_claim, case_type:) }
      let(:fee) { build(:basic_fee, :baf_fee, claim:) }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Guilty pLea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be false }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end

    context 'when claim fee_scheme is ten' do
      let(:claim) { create(:advocate_claim, :agfs_scheme_10, case_type:) }
      let(:fee) { build(:basic_fee, :baf_fee, claim:) }

      before { create(:fee_scheme, :agfs_ten) }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be true }
      end

      context 'when the case type is Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be false }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#build_dates_attended?' do
    subject { helper.build_dates_attended?(fee) }

    let(:claim) { create(:claim, case_type:) }
    let(:fee) { build(:basic_fee, :baf_fee, claim:) }

    context 'when claim is not hardship' do
      before { allow(claim).to receive(:hardship?).and_return false }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end

      context 'when the case type is Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be true }
      end

      context 'when the case type is Discontinuance' do
        let(:case_type) { build(:case_type, :discontinuance) }

        it { is_expected.to be true }
      end
    end

    context 'when claim is hardship' do
      before { allow(claim).to receive(:hardship?).and_return true }

      context 'when the case type is Trial' do
        let(:case_type) { build(:case_type, :trial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Retrial' do
        let(:case_type) { build(:case_type, :retrial) }

        it { is_expected.to be false }
      end

      context 'when the case type is Contempt' do
        let(:case_type) { build(:case_type, :contempt) }

        it { is_expected.to be false }
      end

      context 'when the case type is Guilty plea' do
        let(:case_type) { build(:case_type, :guilty_plea) }

        it { is_expected.to be false }
      end

      context 'when the case type is Discontinuance' do
        let(:case_type) { build(:case_type, :discontinuance) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#trial_dates_fields_classes' do
    subject { helper.trial_dates_fields_classes(show) }

    context 'when fields to be visible' do
      let(:show) { true }

      it { is_expected.to contain_exactly('govuk-!-padding-top-7') }
    end

    context 'when fields not to be visible' do
      let(:show) { false }

      it { is_expected.to contain_exactly('govuk-!-padding-top-7', 'hidden') }
    end
  end
end
