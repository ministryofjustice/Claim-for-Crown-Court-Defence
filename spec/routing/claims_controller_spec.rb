require 'rails_helper'
require 'action_dispatch/routing/polymorphic_routes'

include ActionDispatch::Routing::PolymorphicRoutes

RSpec.describe ExternalUsers::Advocates::ClaimsController do
  it { should route(:get,  '/advocates/claims/new').to(action: :new) }
  it { should route(:post, '/advocates/claims').to(action: :create) }
  it { should route(:put,  '/advocates/claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/advocates/claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { build(:advocate_claim) }

      it { expect(polymorphic_path(claim)).to eq('/advocates/claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { create(:advocate_claim) }

      it { expect(polymorphic_path(claim)).to eq("/advocates/claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/advocates/claims/#{claim.id}/edit") }
    end
  end
end

RSpec.describe ExternalUsers::Advocates::HardshipClaimsController do
  it { should route(:get, '/advocates/hardship_claims/new').to(action: :new) }
  it { should route(:post, '/advocates/hardship_claims').to(action: :create) }
  it { should route(:put, '/advocates/hardship_claims/1').to(action: :update, id: 1) }
  it { should route(:get, '/advocates/hardship_claims/1/edit').to(action: :edit, id: 1) }
end

RSpec.describe ExternalUsers::Litigators::ClaimsController do
  it { should route(:get,  '/litigators/claims/new').to(action: :new) }
  it { should route(:post, '/litigators/claims').to(action: :create) }
  it { should route(:put,  '/litigators/claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { build(:litigator_claim) }

      it { expect(polymorphic_path(claim)).to eq('/litigators/claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { create(:litigator_claim) }

      it { expect(polymorphic_path(claim)).to eq("/litigators/claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/claims/#{claim.id}/edit") }
    end
  end
end

RSpec.describe ExternalUsers::Litigators::InterimClaimsController do
  it { should route(:get,  '/litigators/interim_claims/new').to(action: :new) }
  it { should route(:post, '/litigators/interim_claims').to(action: :create) }
  it { should route(:put,  '/litigators/interim_claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/interim_claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { build(:interim_claim) }

      it { expect(polymorphic_path(claim)).to eq('/litigators/interim_claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { create(:interim_claim) }

      it { expect(polymorphic_path(claim)).to eq("/litigators/interim_claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/interim_claims/#{claim.id}/edit") }
    end
  end
end

RSpec.describe ExternalUsers::Litigators::TransferClaimsController do
  it { should route(:get,  '/litigators/transfer_claims/new').to(action: :new) }
  it { should route(:post, '/litigators/transfer_claims').to(action: :create) }
  it { should route(:put,  '/litigators/transfer_claims/123').to(action: :update, id: 123) }
  it { should route(:get,  '/litigators/transfer_claims/123/edit').to(action: :edit, id: 123) }

  describe 'Route helpers' do
    context 'unpersisted (post)' do
      let(:claim) { build(:transfer_claim) }

      it { expect(polymorphic_path(claim)).to eq('/litigators/transfer_claims') }
    end

    context 'persisted (put or edit)' do
      let(:claim) { create(:transfer_claim) }

      it { expect(polymorphic_path(claim)).to eq("/litigators/transfer_claims/#{claim.id}") }
      it { expect(edit_polymorphic_path(claim)).to eq("/litigators/transfer_claims/#{claim.id}/edit") }
    end
  end
end
