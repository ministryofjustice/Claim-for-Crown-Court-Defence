require 'rails_helper'

RSpec.describe MultiFirmUserLink do
  subject(:link) { build(:multi_firm_user_link, user:, linked_user:) }

  let(:user) { create(:external_user, user: build(:user, multi_firm_user: true)).user }
  let(:linked_user) { create(:external_user).user }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:linked_user).class_name('User') }
  it { is_expected.to validate_uniqueness_of(:linked_user_id) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:linked_user_id) }

  it { is_expected.to be_valid }

  it 'does not link an account to itself' do
    link.linked_user = user

    expect(link).not_to be_valid
  end

  it 'requires the source account to be a multi-firm user' do
    user.update!(multi_firm_user: false)

    expect(link).not_to be_valid
  end

  it 'does not link another multi-firm user' do
    linked_user.update!(multi_firm_user: true)

    expect(link).not_to be_valid
  end

  it 'only links external-user accounts' do
    link.linked_user = create(:case_worker).user

    expect(link).not_to be_valid
  end

  it 'does not link accounts at the same provider' do
    link.linked_user = create(:external_user, provider: user.provider).user

    expect(link).not_to be_valid
  end

  it 'does not allow a linked account to own links' do
    existing_link = create(:multi_firm_user_link)
    link.user = existing_link.linked_user

    expect(link).not_to be_valid
  end

  it 'does not link an account that already owns links' do
    existing_link = create(:multi_firm_user_link)
    link.linked_user = existing_link.user

    expect(link).not_to be_valid
  end
end
