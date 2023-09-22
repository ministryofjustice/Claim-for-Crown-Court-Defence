require 'rails_helper'

RSpec.shared_context 'raise invalid_authenticity_token' do
  before do
    routes.draw { get 'invalid_authenticity_token' => 'anonymous#invalid_authenticity_token' }
    request.env['HTTP_REFERER'] = referer
    get :invalid_authenticity_token
  end
end

RSpec.describe ApplicationController do
  let(:super_admin) { create(:super_admin) }
  let(:advocate) { create(:external_user, :advocate) }
  let(:advocate_admin) { create(:external_user, :admin) }
  let(:case_worker) { create(:case_worker) }
  let(:case_worker_admin) { create(:case_worker, :admin) }

  describe '#after_sign_in_path_for' do
    before { sign_in user }

    context 'given a super admin' do
      let(:user) { super_admin.user }

      it 'returns super admins root url' do
        expect(subject.after_sign_in_path_for(user)).to eq(super_admins_root_url)
      end
    end

    context 'given an advocate' do
      let(:user) { advocate.user }

      it 'returns advocates root url' do
        expect(subject.after_sign_in_path_for(user)).to eq(external_users_root_url)
      end
    end

    context 'given a case worker' do
      let(:user) { case_worker.user }

      it 'returns case workers root url' do
        expect(subject.after_sign_in_path_for(user)).to eq(case_workers_root_url)
      end
    end

    context 'given an admin advocate' do
      let(:user) { advocate_admin.user }

      it 'returns advocates admin root url' do
        expect(subject.after_sign_in_path_for(user)).to eq(external_users_root_url)
      end
    end

    context 'given an admin case worker' do
      let(:user) { case_worker_admin.user }

      it 'returns case workers root url' do
        expect(subject.after_sign_in_path_for(user)).to eq(case_workers_admin_root_url)
      end
    end

    context 'given a user with a different role' do
      let(:user) { build(:user) }

      it 'raises error' do
        expect { subject.after_sign_in_path_for(user) }.to raise_error(NameError)
      end
    end
  end

  describe '#after_sign_out_path_for' do
    before do
      sign_in user
      sign_out user
    end

    context 'given a super admin' do
      let(:user) { super_admin.user }

      it 'returns super admins root url' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given an advocate' do
      let(:user) { advocate.user }

      it 'returns advocates root url' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given a case worker' do
      let(:user) { case_worker.user }

      it 'returns case workers root url' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given an admin advocate' do
      let(:user) { advocate_admin.user }

      it 'returns advocates admin root url' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given an admin case worker' do
      let(:user) { case_worker_admin.user }

      it 'returns case workers root url' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end
  end

  describe '#signed_in_user_profile_path' do
    context 'given a super admin' do
      before { sign_in super_admin.user }

      it 'returns super admins user_profile_path' do
        expect(subject.signed_in_user_profile_path).to eq("/super_admins/admin/super_admins/#{super_admin.id}")
      end
    end

    context 'given an advocate' do
      before { sign_in advocate.user }

      it 'returns advocate user profile path' do
        expect(subject.signed_in_user_profile_path).to eq("/external_users/admin/external_users/#{advocate.id}")
      end
    end

    context 'given a case_worker' do
      before { sign_in case_worker.user }

      it 'returns caseworker Profile path' do
        expect(subject.signed_in_user_profile_path).to eq("/case_workers/admin/case_workers/#{case_worker.id}")
      end
    end

    context 'given a user with a different role' do
      let(:user) { build(:user) }

      it 'raises error' do
        expect { subject.signed_in_user_profile_path }.to raise_error(NameError)
      end
    end
  end

  context 'when an exception is raised' do
    controller do
      skip_load_and_authorize_resource
      def record_not_found = raise(ActiveRecord::RecordNotFound)
      def another_exception = raise(StandardError)
      def invalid_authenticity_token = raise(ActionController::InvalidAuthenticityToken)
    end

    before do
      allow(Sentry).to receive(:capture_exception)
      allow(Rails).to receive(:env).and_return('production'.inquiry)
      request.env['HTTPS'] = 'on'
    end

    context 'with ActiveRecord::RecordNotFound' do
      before do
        routes.draw { get 'record_not_found' => 'anonymous#record_not_found' }
        get :record_not_found
      end

      it { expect(Sentry).not_to have_received(:capture_exception) }
      it { expect(response).to redirect_to(error_404_url) }
    end

    context 'with ActionController::InvalidAuthenticityToken and no referer' do
      include_context 'raise invalid_authenticity_token' do
        let(:referer) { nil }
      end

      it { expect(Sentry).not_to have_received(:capture_exception) }
      it { expect(response).to redirect_to(unauthenticated_root_path) }
    end

    context 'with ActionController::InvalidAuthenticityToken and referer exists' do
      include_context 'raise invalid_authenticity_token' do
        let(:referer) { edit_advocates_claim_path(1) }
      end

      it { expect(Sentry).not_to have_received(:capture_exception) }

      # NOTE: In reality this would further redirect to unauthenticated_root_path
      it { expect(response).to redirect_to(edit_advocates_claim_path(1)) }
    end

    context 'with StandardError' do
      before do
        routes.draw { get 'another_exception' => 'anonymous#another_exception' }
        get :another_exception
      end

      it { expect(Sentry).to have_received(:capture_exception) }
      it { expect(response).to redirect_to(error_500_url) }
    end
  end
end
