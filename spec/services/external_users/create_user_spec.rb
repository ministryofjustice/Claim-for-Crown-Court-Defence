require 'rails_helper'

RSpec.describe ExternalUsers::CreateUser do
  let(:user) { create(:user) }

  subject(:service) { described_class.new(user) }

  describe '#call!' do
    it 'creates a provider with new unique LGFS and firm AGFS supplier numbers' do
      expect { service.call! }
        .to change { Provider.where(provider_type: 'firm').count }.by(1)

      new_provider = Provider.order('created_at').last
      expect(new_provider.lgfs_supplier_numbers.size).to eq(1)
      expect(new_provider.lgfs_supplier_numbers.first.supplier_number).to match(/^9X\d{3}X$/)
    end

    it 'creates an external user related with the provided user and the created provider' do
      expect { service.call! }
        .to change { ExternalUser.count }.by(1)

      new_provider = Provider.order('created_at').last
      new_external_user = ExternalUser.order('created_at').last
      expect(new_external_user.user).to eq(user)
      expect(new_external_user.provider).to eq(new_provider)
    end

    context 'when the provider is not created due to some error' do
      before do
        expect(Provider)
          .to receive(:create!)
          .with(any_args)
          .and_raise(StandardError, 'BOOM!!!')
      end

      it 'does not create an external user related with the provided user' do
        expect { service.call! rescue nil }
          .not_to change { ExternalUser.count }
      end
    end
  end
end
