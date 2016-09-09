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
      allow(Settings).to receive(:timed_retention_banner_enabled?).and_return(timed_retention_banner_enabled)
      allow(current_user).to receive(:settings).and_return(user_settings)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'feature flag enabled' do
      let(:timed_retention_banner_enabled) { true }

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
        let(:user_settings) { {timed_retention_banner_seen: '1'} }

        it 'should return false' do
          expect(helper.show_timed_retention_banner_to_user?).to be_falsey
        end
      end
    end

    context 'feature flag disabled' do
      let(:timed_retention_banner_enabled) { false }

      it 'should return false regardless of the user setting' do
        expect(helper).not_to receive(:current_user)
        expect(helper.show_timed_retention_banner_to_user?).to be_falsey
      end
    end
  end
end