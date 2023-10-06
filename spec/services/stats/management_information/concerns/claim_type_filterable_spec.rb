# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::Concerns::ClaimTypeFilterable do
  let(:agfs_in_statement) do
    <<~STATEMENT.squish.squeeze(' ')
      ('Claim::AdvocateClaim',
      'Claim::AdvocateInterimClaim',
      'Claim::AdvocateSupplementaryClaim',
      'Claim::AdvocateHardshipClaim')
    STATEMENT
  end

  let(:lgfs_in_statement) do
    <<~STATEMENT.squish.squeeze(' ')
      ('Claim::LitigatorClaim',
      'Claim::InterimClaim',
      'Claim::TransferClaim',
      'Claim::LitigatorHardshipClaim')
    STATEMENT
  end

  let(:all_in_statement) do
    <<~STATEMENT.squish.squeeze(' ')
      ('Claim::AdvocateClaim',
      'Claim::AdvocateInterimClaim',
      'Claim::AdvocateSupplementaryClaim',
      'Claim::AdvocateHardshipClaim',
      'Claim::LitigatorClaim',
      'Claim::InterimClaim',
      'Claim::TransferClaim',
      'Claim::LitigatorHardshipClaim')
    STATEMENT
  end

  describe 'MockClaimTypeFilter' do
    before do
      stub_const('MockClaimTypeFilter', mock_claim_type_filter)
    end

    let(:instance) { MockClaimTypeFilter.new }

    let(:mock_claim_type_filter) do
      Class.new do
        include Stats::ManagementInformation::Concerns::ClaimTypeFilterable
      end
    end

    specify { expect(MockClaimTypeFilter).to respond_to(:acts_as_scheme) }

    specify do
      expect(instance).to respond_to(:scheme, :scheme=,
                                     :claim_types, :agfs_claim_types, :lgfs_claim_types,
                                     :claim_type_filter, :in_statement_for)
    end

    it { expect(instance).to delegate_method(:claim_types).to(:base_claim_klass) }
    it { expect(instance).to delegate_method(:agfs_claim_types).to(:base_claim_klass) }
    it { expect(instance).to delegate_method(:lgfs_claim_types).to(:base_claim_klass) }

    describe '#scheme' do
      subject { instance.scheme }

      it { is_expected.to be_nil }
    end

    describe '#claim_type_filter' do
      subject(:claim_type_filter) { instance.claim_type_filter }

      it 'returns AGFS claims types in statement when scheme set to AGFS' do
        instance.scheme = :agfs
        expect(claim_type_filter).to eql(agfs_in_statement)
      end

      it 'returns LGFS claims types in statement when scheme set to LGFS' do
        instance.scheme = :lgfs
        expect(claim_type_filter).to eql(lgfs_in_statement)
      end

      it 'returns all claim types in statement when scheme not set' do
        expect(claim_type_filter).to eql(all_in_statement)
      end
    end
  end

  describe 'MockClaimTypeFilterWithInitializer' do
    before do
      stub_const('MockClaimTypeFilterWithInitializer', mock_claim_type_filter_with_initilizer)
    end

    let(:mock_claim_type_filter_with_initilizer) do
      Class.new do
        include Stats::ManagementInformation::Concerns::ClaimTypeFilterable

        def initialize(**kwargs)
          @scheme = kwargs[:scheme]
        end
      end
    end

    describe '#scheme' do
      subject { MockClaimTypeFilterWithInitializer.new(scheme: :foobar).scheme }

      it { is_expected.to eql('FOOBAR') }
    end

    describe '#claim_type_filter' do
      subject(:claim_type_filter) { instance.claim_type_filter }

      context 'with LGFS scheme arg' do
        let(:instance) { MockClaimTypeFilterWithInitializer.new(scheme: :lgfs) }

        it 'returns LGFS claims types in statement' do
          expect(claim_type_filter).to eql(lgfs_in_statement)
        end
      end

      context 'with AGFS scheme arg' do
        let(:instance) { MockClaimTypeFilterWithInitializer.new(scheme: :agfs) }

        it 'returns AGFS claims types in statement' do
          expect(claim_type_filter).to eql(agfs_in_statement)
        end
      end

      context 'with nil scheme' do
        let(:instance) { MockClaimTypeFilterWithInitializer.new }

        it 'returns all claims types in statement' do
          expect(claim_type_filter).to eql(all_in_statement)
        end
      end
    end
  end

  describe 'MockAGFSClaimTypeFilter' do
    before do
      stub_const('MockAGFSClaimTypeFilter', mock_agfs_claim_type_filter)
    end

    let(:mock_agfs_claim_type_filter) do
      Class.new do
        include Stats::ManagementInformation::Concerns::ClaimTypeFilterable

        acts_as_scheme :agfs
      end
    end

    let(:instance) { MockAGFSClaimTypeFilter.new }

    describe '#scheme' do
      subject { instance.scheme }

      it { is_expected.to eql('AGFS') }
    end

    describe '#claim_type_filter' do
      subject(:claim_type_filter) { instance.claim_type_filter }

      it 'returns AGFS claim types in statement even when scheme set to :lgfs' do
        instance.scheme = :lgfs
        expect(claim_type_filter).to eql(agfs_in_statement)
      end

      it 'returns AGFS claim types in statement even when scheme set to nil' do
        expect(claim_type_filter).to eql(agfs_in_statement)
      end
    end
  end

  describe 'MockLGFSClaimTypeFilter' do
    before do
      stub_const('MockLGFSClaimTypeFilter', mock_lgfs_claim_type_filter)
    end

    let(:mock_lgfs_claim_type_filter) do
      Class.new do
        include Stats::ManagementInformation::Concerns::ClaimTypeFilterable

        acts_as_scheme :lgfs
      end
    end

    let(:instance) { MockLGFSClaimTypeFilter.new }

    describe '#scheme' do
      subject { instance.scheme }

      it { is_expected.to eql('LGFS') }
    end

    describe '#claim_type_filter' do
      subject(:claim_type_filter) { instance.claim_type_filter }

      it 'returns LGFS claim types in statement even when scheme set to :agfs' do
        instance.scheme = :agfs
        expect(claim_type_filter).to eql(lgfs_in_statement)
      end

      it 'returns LGFS claim types in statement even when scheme set to nil' do
        expect(claim_type_filter).to eql(lgfs_in_statement)
      end
    end
  end
end
