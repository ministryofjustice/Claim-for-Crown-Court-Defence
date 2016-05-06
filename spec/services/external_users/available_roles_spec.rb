require 'rails_helper'

RSpec.describe ExternalUsers::AvailableRoles do
  subject { ExternalUsers::AvailableRoles }

  describe '.call' do
    let(:advocate)            { create(:external_user, :advocate)           }
    let(:litigator)           { create(:external_user, :litigator)          }
    let(:advocate_litigator)  { create(:external_user, :advocate_litigator) }

    context 'when the user does not belong to a provider' do
      it 'returns admin' do
        advocate.provider = nil
        expect(subject.call(advocate)).to eq ['admin']
      end
    end
    context 'when the user belongs to a provider that' do
      context 'handles both AGFS and LGFS claims' do
        it 'returns admin advocate and litigator' do
          expect(subject.call(advocate_litigator)).to eq ['admin', 'advocate', 'litigator']
        end
      end
      context 'handles only AGFS claims' do
        it 'returns admin and advocate' do
          expect(subject.call(advocate)).to eq ['admin', 'advocate']
        end
      end
      context 'handles only LGFS claims' do
        it 'returns admin and litigator' do
          expect(subject.call(litigator)).to eq ['admin', 'litigator']
        end
      end
    end
    context 'when an invalid fee scheme is used' do
      it 'raises an error' do
        advocate.provider.roles = %w( invalid_role )
        expect { subject.call(advocate) }.to raise_error
      end
    end
  end
end
