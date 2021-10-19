# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::DailyReportQuery do
  describe '.call' do
    subject(:response) { described_class.call }

    let(:scheme_class) { Stats::ManagementInformation::Scheme }

    it {
      create(:advocate_final_claim, :submitted)
      expect(response).to be_a(Array)
    }

    it {
      create(:advocate_final_claim, :submitted)
      expect(response).to all(be_a(Hash))
    }

    it {
      create(:advocate_final_claim, :submitted)
      keys = response.flat_map(&:keys)
      expect(keys).to all(be_a(Symbol))
    }

    context 'with no scope' do
      subject(:response) { described_class.call }

      it 'returns active claims only' do
        create(:advocate_final_claim, :authorised).soft_delete
        create(:litigator_final_claim, :submitted)
        deleted_ats = response.pluck(:deleted_at)

        expect(deleted_ats).to all(be_nil)
      end

      it 'returns non-draft claims only' do
        create(:advocate_final_claim, :draft)
        create(:litigator_final_claim, :submitted)
        states = response.pluck(:state)

        expect(states).to match_array(%w[submitted])
      end

      it 'returns all claim types' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::AdvocateClaim Claim::LitigatorClaim])
      end
    end

    context 'with invalid scheme scope' do
      subject(:call) { described_class.call({ scheme: scheme }) }

      let(:scheme) { :foobar }

      it { expect { call }.to raise_error ArgumentError, 'scheme must be "agfs" or "lgfs"' }
    end

    context 'with AGFS scheme scope' do
      subject(:response) { described_class.call({ scheme: scheme }) }

      let(:scheme) { :agfs }

      it 'returns AGFS claims only' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::AdvocateClaim])
      end
    end

    context 'with LGFS claim scope' do
      subject(:response) { described_class.call({ scheme: scheme }) }

      let(:scheme) { :lgfs }

      it 'returns LGFS claims only' do
        create(:advocate_final_claim, :submitted)
        create(:litigator_final_claim, :submitted)
        types = response.pluck(:type)

        expect(types).to match_array(%w[Claim::LitigatorClaim])
      end
    end

    describe 'scheme' do
      subject { response.pluck(:scheme) }

      context 'with AGFS claim' do
        before { create(:advocate_final_claim, :submitted) }

        it { is_expected.to match_array(%w[AGFS]) }
      end

      context 'with LGFS claim' do
        before { create(:litigator_final_claim, :submitted) }

        it { is_expected.to match_array(%w[LGFS]) }
      end
    end

    describe 'organisation' do
      subject { response.pluck(:organisation) }

      let!(:claim) { create(:advocate_final_claim, :submitted) }

      it { is_expected.to match_array([claim.provider.name]) }
    end

    describe 'case_type_name' do
      subject { response.pluck(:case_type_name) }

      let!(:claim) { create(:advocate_final_claim, :submitted) }

      it { is_expected.to match_array([claim.case_type.name]) }
    end

    describe 'bill_type' do
      subject { response.pluck(:bill_type) }

      context 'with advocate final claim' do
        before { create(:advocate_final_claim, :submitted) }

        it { is_expected.to match_array(['AGFS Final']) }
      end

      context 'with advocate supplementary claim' do
        before { create(:advocate_supplementary_claim, :submitted) }

        it { is_expected.to match_array(['AGFS Supplementary']) }
      end

      context 'with litigator final claim' do
        before { create(:litigator_final_claim, :submitted) }

        it { is_expected.to match_array(['LGFS Final']) }
      end

      context 'with litigator transfer claim' do
        before { create(:litigator_transfer_claim, :submitted) }

        it { is_expected.to match_array(['LGFS Transfer']) }
      end
    end

    describe 'claim_total' do
      subject { response.pluck(:claim_total) }

      let!(:claim) { create(:litigator_final_claim, :submitted) }

      it { is_expected.to match_array([claim.total_including_vat.to_s]) }
    end

    context 'with claim state transitions' do
      subject(:response) { described_class.call }

      let(:transition_tos) { response.pluck(:journey).map { |el| el.pluck(:to) } }

      it 'excludes state transitions to draft' do
        create(:advocate_final_claim, :allocated)
        expect(transition_tos).to match_array([%w[submitted allocated]])
      end

      it 'excludes state transitions to archived_pending_delete' do
        create(:litigator_final_claim, :archived_pending_delete)
        expect(transition_tos).to match_array([%w[submitted allocated authorised]])
      end

      it 'excludes state transitions to archived_pending_review' do
        create(:litigator_hardship_claim, :archived_pending_review)
        expect(transition_tos).to match_array([%w[submitted allocated authorised]])
      end

      context 'when claim has transitions on or under 6 months old' do
        before do
          travel_to(6.months.ago + 1.day) { claim }
          claim.allocate!
        end

        let(:claim) { create(:litigator_final_claim, :submitted) }

        it 'include all state transitions' do
          expect(transition_tos).to match_array([%w[submitted allocated]])
        end
      end

      # TODO: The six month exclusion was only applied to handle failing reports and/or
      # keep the spreadsheet small for filtering purposes. It could be removed
      # if these problems are no longer issues.
      context 'when claim has transitions over 6 months old' do
        before do
          travel_to(6.months.ago) { claim }
          claim.allocate!
        end

        let(:claim) { create(:litigator_final_claim, :submitted) }

        it 'excludes state transitions over 6 months old' do
          expect(transition_tos).to match_array([%w[allocated]])
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it 'excludes deallocations and deallocated allocations' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
        end

        expect(transition_tos).to eq([%w[submitted]])
      end

      it 'excludes deallocations and all but last allocation' do
        create(:advocate_final_claim, :allocated).tap do |claim|
          claim.deallocate!
          claim.allocate!
          claim.deallocate!
          claim.allocate!
        end

        expect(transition_tos).to eq([%w[submitted allocated]])
      end

      context 'with a redetermination' do
        it 'slices transitions into "completed" chunks' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.refuse!
          end

          expect(transition_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
        end

        it 'slices transitions into "completed" chunks plus remainder' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.refuse!
            claim.redetermine!
            claim.allocate!
          end

          expect(transition_tos).to eq([%w[submitted allocated part_authorised],
                                        %w[redetermination allocated refused],
                                        %w[redetermination allocated]])
        end

        it 'excludes deallocations and deallocated allocations per slice' do
          create(:advocate_final_claim, :allocated).tap do |claim|
            claim.deallocate!
            claim.allocate!
            claim.deallocate!
            claim.allocate!

            claim.tap do |c|
              assign_fees_and_expenses_for(c)
              c.authorise_part!
            end

            claim.redetermine!
            claim.allocate!
            claim.deallocate!
            claim.allocate!
            claim.refuse!
          end

          expect(transition_tos).to eq([%w[submitted allocated part_authorised], %w[redetermination allocated refused]])
        end
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
