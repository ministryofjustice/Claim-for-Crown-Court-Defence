require 'rails_helper'

RSpec.describe MultiFirmUserLinker do
  subject(:linker) { described_class.new(user:, email:, password:) }

  let(:user) { create(:external_user, user: build(:user, multi_firm_user: true)).user }
  let(:linked_user) { create(:external_user).user }
  let(:email) { linked_user.email }
  let(:password) { 'PasswordForTest' }

  it 'creates a link with valid legacy credentials' do
    expect { linker.save }.to change(MultiFirmUserLink, :count).by(1)
  end

  it 'makes a linked account available to the primary user' do
    linker.save

    expect(user.linked_users).to contain_exactly(linked_user)
  end

  it 'normalises the target email address' do
    linker.email = " #{linked_user.email.upcase} "

    expect(linker.save).to be(true)
  end

  context 'with invalid credentials' do
    before { linker.password = 'incorrect-password' }

    it 'does not create a link' do
      expect { linker.save }.not_to change(MultiFirmUserLink, :count)
    end

    it 'returns a generic credential error' do
      linker.save

      expect(linker.errors[:base]).to contain_exactly('The email or password is incorrect')
    end
  end

  context 'when the account does not exist' do
    before { linker.email = 'missing@example.com' }

    it 'does not save' do
      expect(linker.save).to be(false)
    end

    it 'returns the same generic credential error' do
      linker.save

      expect(linker.errors[:base]).to contain_exactly('The email or password is incorrect')
    end
  end

  context 'when the link is invalid' do
    before { linked_user.update!(multi_firm_user: true) }

    it 'does not save' do
      expect(linker.save).to be(false)
    end

    it 'returns link validation errors' do
      linker.save

      expect(linker.errors[:base]).to include('Linked user cannot be a multi-firm user')
    end
  end
end
