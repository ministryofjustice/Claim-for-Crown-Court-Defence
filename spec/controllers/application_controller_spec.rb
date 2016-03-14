require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#after_sign_in_path_for' do
    let(:super_admin) { create(:super_admin) }
    let(:advocate) { create(:external_user, :advocate) }
    let(:advocate_admin) { create(:external_user, :admin) }
    let(:case_worker) { create(:case_worker) }
    let(:case_worker_admin) { create(:case_worker, :admin) }

    context 'given a super admin' do
      before { sign_in super_admin.user }

      it 'returns super admins root url' do
        expect(subject.after_sign_in_path_for(super_admin.user)).to eq(super_admins_root_url)
      end

    end

    context 'given an advocate' do
      before { sign_in advocate.user }

      it 'returns advocates root url ' do
        expect(subject.after_sign_in_path_for(advocate.user)).to eq(external_users_root_url)
      end
    end

    context 'given a case worker' do
      before { sign_in case_worker.user }

      it 'returns case workers root url ' do
        expect(subject.after_sign_in_path_for(case_worker.user)).to eq(case_workers_root_url)
      end
    end

    context 'given an admin advocate' do
      before { sign_in advocate_admin.user }

      it 'returns advocates admin root url ' do
        expect(subject.after_sign_in_path_for(advocate_admin.user)).to eq(external_users_root_url)
      end
    end

    context 'given an admin case worker' do
      before { sign_in case_worker_admin.user }

      it 'returns case workers root url ' do
        expect(subject.after_sign_in_path_for(case_worker_admin.user)).to eq(case_workers_admin_root_url)
      end
    end

    context 'given a user with a different role' do
      before { user = build(:user); sign_in user }

      it 'raises error' do
        expect { subject.after_sign_in_path_for(user) }.to raise_error
      end
    end
  end

  describe '#after_sign_out_path_for' do
    let(:super_admin) { create(:super_admin) }
    let(:advocate) { create(:external_user, :advocate) }
    let(:advocate_admin) { create(:external_user, :admin) }
    let(:case_worker) { create(:case_worker) }
    let(:case_worker_admin) { create(:case_worker, :admin) }

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

      it 'returns advocates root url ' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given a case worker' do
      let(:user) { case_worker.user }

      it 'returns case workers root url ' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given an admin advocate' do
      let(:user) { advocate_admin.user }

      it 'returns advocates admin root url ' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end

    context 'given an admin case worker' do
      let(:user) { case_worker_admin.user }

      it 'returns case workers root url ' do
        expect(subject.after_sign_out_path_for(user)).to eq(new_feedback_url(type: 'feedback'))
      end
    end
  end
end
