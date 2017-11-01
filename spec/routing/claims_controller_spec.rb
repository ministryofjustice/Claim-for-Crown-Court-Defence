require 'rails_helper'
require 'action_dispatch/routing/polymorphic_routes'

include ActionDispatch::Routing::PolymorphicRoutes

describe ExternalUsers::Advocates::ClaimsController, type: :routing do

  it { should route(:get,  '/advocates/claims/new').to(action: :new) }
  it { should route(:post, '/advocates/claims').to(action: :create) }
  it { should route(:put,  '/advocates/claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/advocates/claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { FactoryBot.build(:advocate_claim) }
      it { expect(polymorphic_path(claim)).to eq('/advocates/claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { FactoryBot.create(:advocate_claim) }
      it { expect(polymorphic_path(claim)).to eq("/advocates/claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/advocates/claims/#{claim.id}/edit") }
    end
  end
end

describe ExternalUsers::Litigators::ClaimsController, type: :routing do

  it { should route(:get,  '/litigators/claims/new').to(action: :new) }
  it { should route(:post, '/litigators/claims').to(action: :create) }
  it { should route(:put,  '/litigators/claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { FactoryBot.build(:litigator_claim) }
      it { expect(polymorphic_path(claim)).to eq('/litigators/claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { FactoryBot.create(:litigator_claim) }
      it { expect(polymorphic_path(claim)).to eq("/litigators/claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/claims/#{claim.id}/edit") }
    end
  end
end

describe ExternalUsers::Litigators::InterimClaimsController, type: :routing do

  it { should route(:get,  '/litigators/interim_claims/new').to(action: :new) }
  it { should route(:post, '/litigators/interim_claims').to(action: :create) }
  it { should route(:put,  '/litigators/interim_claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/interim_claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { FactoryBot.build(:interim_claim) }
      it { expect(polymorphic_path(claim)).to eq('/litigators/interim_claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { FactoryBot.create(:interim_claim) }
      it { expect(polymorphic_path(claim)).to eq("/litigators/interim_claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/interim_claims/#{claim.id}/edit") }
    end
  end
end

describe ExternalUsers::Litigators::TransferClaimsController, type: :routing do

  it { should route(:get,  '/litigators/transfer_claims/new').to(action: :new) }
  it { should route(:post, '/litigators/transfer_claims').to(action: :create) }
  it { should route(:put,  '/litigators/transfer_claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/transfer_claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { FactoryBot.build(:transfer_claim) }
      it { expect(polymorphic_path(claim)).to eq('/litigators/transfer_claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { FactoryBot.create(:transfer_claim) }
      it { expect(polymorphic_path(claim)).to eq("/litigators/transfer_claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/transfer_claims/#{claim.id}/edit") }
    end
  end
end
