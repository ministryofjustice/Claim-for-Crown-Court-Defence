require 'rails_helper'
require 'support/shared_examples_for_claim_types'

RSpec.describe Claims::ContextMapper do
  # NOTE: the external user claim controller spec also test this to a degree
  #
  describe '#available_claim_types' do
    subject { context.available_claim_types.map(&:to_s) }
    let(:context) { Claims::ContextMapper.new(external_user) }
    let(:external_user) { create(:external_user, :advocate_litigator) }

    include_context 'claim-types object helpers'

    # TODO: i believe this is flawed as an advocate should return only advocate type claims)
    # e.g. an admin in an agfs only provider can only create advocate claims
    context 'AGFS only provider' do
      let(:external_user) { create(:external_user, :advocate, provider: build(:provider, :agfs)) }

      it { is_expected.to match_array(agfs_claim_object_types) }
    end

    context 'LGFS only provider' do
      let(:external_user) { create(:external_user, :litigator, provider: build(:provider, :lgfs)) }

      it { is_expected.to match_array(lgfs_claim_object_types) }
    end

    context 'AGFS and LGFS providers' do
      it 'should return litigator claim for a litigators' do
        external_user.roles = ['litigator']
        is_expected.to match_array(lgfs_claim_object_types)
      end

      it 'should return litigator and advocate claim for a litigator admins' do
        external_user.roles = ['litigator', 'admin']
        is_expected.to match_array(all_claim_object_types)
      end

      it 'should return advocate claim for a advocates' do
        external_user.roles = ['advocate']
        is_expected.to match_array(agfs_claim_object_types)
      end

      it 'should return advocate and litigator claim for a advocate admins' do
        external_user.roles = ['advocate', 'admin']
        is_expected.to match_array(all_claim_object_types)
      end

      it 'should return advocate AND litigator claims for a admins' do
        external_user.roles = ['admin']
        is_expected.to match_array(all_claim_object_types)
      end

      it 'should return advocate AND litigator claims for users with admin, litigator and advocate roles' do
        external_user.roles = ['admin', 'advocate', 'litigator']
        is_expected.to match_array(all_claim_object_types)
      end
    end
  end

  describe '#available_schemes' do
    let(:external_user) { create(:external_user, :advocate_litigator) }
    let(:advocate) { create(:external_user, :advocate) }
    let(:litigator) { create(:external_user, :litigator) }

    it 'for users in AGFS only provider' do
      context = Claims::ContextMapper.new(advocate)
      expect(context.available_schemes).to match_array([:agfs])
    end

    it 'for users in LGFS only provider' do
      context = Claims::ContextMapper.new(litigator)
      expect(context.available_schemes).to match_array([:lgfs])
    end

    context 'AGFS and LGFS providers' do
      [
        [%w(advocate),                  [:agfs]],
        [%w(litigator),                 [:lgfs]],
        [%w(admin),                     [:agfs, :lgfs]],
        [%w(litigator admin),           [:agfs, :lgfs]],
        [%w(advocate admin),            [:agfs, :lgfs]],
        [%w(admin advocate litigator),  [:agfs, :lgfs]]
      ].each do |(roles, schemes)|
        it "returns the schemes #{schemes} for roles #{roles}" do
          external_user.roles = roles
          context = Claims::ContextMapper.new(external_user)
          expect(context.available_schemes).to match_array(schemes)
        end
      end
    end
  end

  describe '#available_claims' do
    before(:all) do
      @agfs_provider    = create :provider, :agfs
      @lgfs_provider    = create :provider, :lgfs
      @both_provider    = create :provider, :agfs_lgfs
      @advocate         = create(:external_user, :advocate, provider: @agfs_provider)
      @advocate_admin   = create(:external_user, :advocate_and_admin, provider: @agfs_provider)
      @litigator        = create(:external_user, :litigator, provider: @lgfs_provider)
      @litigator_admin  = create(:external_user, :litigator_and_admin, provider: @lgfs_provider)
      @agfs_lgfs_admin  = create(:external_user, :advocate_litigator, provider: @both_provider)
      @other_litigator  = create(:external_user, :litigator, provider: @lgfs_provider)
    end

    after(:all) do
      clean_database
    end

    context 'AGFS' do
      before do
        create_list(:advocate_claim, 2, external_user: @advocate)
        create_list(:advocate_claim, 1, external_user: @advocate_admin)
      end

      it 'advocate context should return all claims owned by the advocate' do
        context = Claims::ContextMapper.new(@advocate)
        expect(context.available_claims).to eq(@advocate.claims)
      end

      it 'advocate admin context should return all claims owned by the provider' do
        context = Claims::ContextMapper.new(@advocate_admin)
        expect(context.available_claims).to eq(@advocate_admin.provider.claims)
        expect(context.available_claims.count).to eq 3
      end
    end

    context 'LGFS' do
      before do
        create_list(:litigator_claim, 2, external_user: @litigator, creator: @litigator)
        create_list(:litigator_claim, 1, external_user: @litigator, creator: @litigator_admin)
        create_list(:litigator_claim, 1, external_user: @other_litigator, creator: @litigator_admin)
      end

      it 'litigator context should return all claims owned by the external user' do
        context = Claims::ContextMapper.new(@litigator)
        expected_claim_ids = Claim::BaseClaim.where(external_user_id: @litigator.id).pluck(:id).sort
        expect(context.available_claims.map(&:id).sort).to eq(expected_claim_ids)
        expect(context.available_claims.count).to eq 3
      end

      it 'litigator admin context should return all claims created by members of the provider' do
        context = Claims::ContextMapper.new(@litigator_admin)
        external_user_ids = ExternalUser.where(provider_id: @lgfs_provider).pluck(:id).sort
        expected_ids = Claim::LitigatorClaim.where('external_user_id in (?)', external_user_ids).pluck(:id)
        expect(context.available_claims.pluck(:id).sort).to eq(expected_ids.sort)
        expect(context.available_claims.count).to eq 4
      end
    end
  end

  context 'AGFS/LGFS' do
    before(:all) do
      @provider    = create :provider, :agfs_lgfs
      @litigator_1 = create :external_user, :litigator, provider: @provider
      @litigator_2 = create :external_user, :litigator, provider: @provider
      @advocate_1  = create :external_user, :advocate, provider: @provider
      @advocate_2  = create :external_user, :advocate, provider: @provider
      @claim_l1    = create :litigator_claim, external_user: @litigator_1, creator: @litigator_1
      @claim_l2    = create :litigator_claim, external_user: @litigator_2, creator: @litigator_2
      @claim_a1    = create :advocate_claim, external_user: @advocate_1, creator: @advocate_1
      @claim_a2    = create :advocate_claim, external_user: @advocate_2, creator: @advocate_2
      @admin       = create(:external_user, :agfs_lgfs_admin, provider: @provider)
    end

    after(:all) do
      clean_database
    end

    it 'returns all claims for the provider for the admin context' do
      expected_ids = [@claim_l1.id, @claim_l2.id, @claim_a1.id, @claim_a2.id].sort
      actual_ids = Claims::ContextMapper.new(@admin).available_claims.map(&:id).sort
      expect(actual_ids).to eq expected_ids
    end

    it 'returns all claims for the external user' do
      expected_ids = [@claim_a1.id]
      actual_ids = Claims::ContextMapper.new(@advocate_1).available_claims.map(&:id).sort
      expect(actual_ids).to eq expected_ids
    end

    context 'for AGFS scheme filter' do
      let(:options) { { scheme: :agfs } }

      it 'returns all AGFS claims for the provider for the admin context' do
        expected_ids = [@claim_a1.id, @claim_a2.id].sort
        actual_ids = Claims::ContextMapper.new(@admin, options).available_claims.map(&:id).sort
        expect(actual_ids).to eq expected_ids
      end

      it 'returns all AGFS claims for the external user' do
        expected_ids = [@claim_a1.id]
        actual_ids = Claims::ContextMapper.new(@advocate_1, options).available_claims.map(&:id).sort
        expect(actual_ids).to eq expected_ids
      end
    end

    context 'for LGFS scheme filter' do
      let(:options) { { scheme: :lgfs } }

      it 'returns all LGFS claims for the provider for the admin context' do
        expected_ids = [@claim_l1.id, @claim_l2.id].sort
        actual_ids = Claims::ContextMapper.new(@admin, options).available_claims.map(&:id).sort
        expect(actual_ids).to eq expected_ids
      end

      it 'returns all LGFS claims for the external user' do
        expected_ids = []
        actual_ids = Claims::ContextMapper.new(@advocate_1, options).available_claims.map(&:id).sort
        expect(actual_ids).to eq expected_ids
      end
    end
  end
end
