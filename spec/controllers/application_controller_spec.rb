require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#after_sign_in_path_for' do
    let(:advocate) { create(:advocate) }
    let(:case_worker) { create(:case_worker) }

    context 'given an advocate' do
      it 'returns advocates root url ' do
        expect(subject.after_sign_in_path_for(advocate)).to eq(advocates_root_url)
      end
    end

    context 'given a case worker' do
      it 'returns case workers root url ' do
        expect(subject.after_sign_in_path_for(case_worker)).to eq(case_workers_root_url)
      end
    end

    context 'given a user with a different role' do
      it 'raises error' do
        user = build(:user, role: 'foo')
        expect { subject.after_sign_in_path_for(user) }.to raise_error
      end
    end
  end
end
