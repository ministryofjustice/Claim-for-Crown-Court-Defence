require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#after_sign_in_path_for' do
    let(:advocate) { create(:advocate) }
    let(:case_worker) { create(:case_worker) }
    let(:admin) { create(:admin) }

    context 'given an advocate' do
      before { sign_in advocate.user }

      it 'returns advocates root url ' do
        expect(subject.after_sign_in_path_for(advocate.user)).to eq(advocates_root_url)
      end
    end

    context 'given a case worker' do
      before { sign_in case_worker.user }

      it 'returns case workers root url ' do
        expect(subject.after_sign_in_path_for(case_worker.user)).to eq(case_workers_root_url)
      end
    end

    # context 'given an admin case worker' do
    #   before { sign_in admin.user }
    #
    #   it 'returns case workers root url ' do
    #     expect(subject.after_sign_in_path_for(case_worker.user)).to eq(admin_root_url)
    #   end
    # end

    context 'given a user with a different role' do
      before { user = build(:user); sign_in user }

      it 'raises error' do
        expect { subject.after_sign_in_path_for(user) }.to raise_error
      end
    end
  end
end
