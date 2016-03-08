require 'rails_helper'

RSpec.describe Claims::ContextMapper do

  # NOTE: the external user claim controller spec also test this to a degree
  #

  describe '#available_claim_types' do

    let(:external_user)   { create(:external_user, :advocate_litigator) }
    let(:advocate)      { create(:external_user, :advocate) }
    let(:litigator)     { create(:external_user, :litigator) }


    it 'should return advocate claims for users in AGFS only provider' do
      context = Claims::ContextMapper.new(advocate)
      expect(context.available_claim_types).to eql [Claim::AdvocateClaim]
    end

    it 'should return litigator claims for users in LGFS only provider' do
      context = Claims::ContextMapper.new(litigator)
      expect(context.available_claim_types).to eql [Claim::LitigatorClaim]
    end

    context 'AGFS and LGFS providers' do

      it 'should return litigator claim for a litigators' do
        external_user.roles = ['litigator']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::LitigatorClaim]
      end
      it 'should return litigator claim for a litigator admins' do
        external_user.roles = ['litigator','admin']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::LitigatorClaim]
      end
      it 'should return advocate claim for a advocates' do
        external_user.roles = ['advocate']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::AdvocateClaim]
      end
      it 'should return advocate claim for a advocate admins' do
        external_user.roles = ['advocate','admin']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::AdvocateClaim]
      end
      it 'should return advocate AND litigator claims for a admins' do
        external_user.roles = ['admin']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::AdvocateClaim,Claim::LitigatorClaim]
      end
      it 'should return advocate AND litigator claims for users with admin, litigator and advocate roles' do
        external_user.roles = ['admin','advocate','litigator']
        context = Claims::ContextMapper.new(external_user)
        expect(context.available_claim_types).to eql [Claim::AdvocateClaim,Claim::LitigatorClaim]
      end

    end

  end

  describe '#available_claims' do

    let!(:advocate)       { create(:external_user, :advocate) }
    let!(:advocate_admin) { create(:external_user, :advocate_and_admin, provider: advocate.provider) }
    let!(:litigator)      { create(:external_user, :litigator) }
    let!(:litigator_admin){ create(:external_user, :litigator_and_admin, provider: litigator.provider) }
    let!(:agfs_lgfs_admin){ create(:external_user, :advocate_litigator) }

    context 'AGFS' do
      before do
        create_list(:advocate_claim, 2, external_user: advocate)
        create_list(:advocate_claim, 1, external_user: advocate_admin)
      end

      it 'advocate context should return all claims owned by the advocate' do
        context = Claims::ContextMapper.new(advocate)
        expect(context.available_claims).to eq(advocate.claims)
      end

      it 'advocate admin context should return all claims owned by the provider' do
        context = Claims::ContextMapper.new(advocate_admin)
        expect(context.available_claims).to eq(advocate_admin.provider.claims)
        expect(context.available_claims.count).to eq 3
      end
    end

    context 'LGFS' do
      before do
        create_list(:litigator_claim, 2, creator: litigator)
        create_list(:litigator_claim, 1, creator: litigator_admin)
      end

      it 'litigator context should return all claims created by members of the provider' do
        context = Claims::ContextMapper.new(litigator)
        expect(context.available_claims).to eq(litigator.provider.claims_created)
        expect(context.available_claims.count).to eq 3
      end

      it 'litigator admin context should return all claims created by members of the provider' do
        context = Claims::ContextMapper.new(litigator_admin)
        expect(context.available_claims).to eq(litigator_admin.provider.claims_created)
        expect(context.available_claims.count).to eq 3
      end
    end
    
    context 'AGFS/LGFS' do
      before do
        create_list(:advocate_claim, 2, external_user: advocate)
        create_list(:advocate_claim, 1, external_user: advocate_admin)
        create_list(:litigator_claim, 2, creator: litigator)
        create_list(:litigator_claim, 1, creator: litigator_admin)
        agfs_lgfs_admin.roles << 'admin'
        [advocate, advocate_admin, litigator, litigator_admin].each do |external_user|
          external_user.provider = agfs_lgfs_admin.provider
          external_user.save!
        end
      end

      it 'admin context should return all claims created or owned by members of the provider' do
        context = Claims::ContextMapper.new(agfs_lgfs_admin)
        expect(context.available_claims).to eq(agfs_lgfs_admin.provider.claims_created.merge!(agfs_lgfs_admin.provider.claims))
        expect(context.available_claims.count).to eq 6
      end
    end

  end

end
