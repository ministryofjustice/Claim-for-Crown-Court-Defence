# frozen_string_literal: true

RSpec.describe Stats::ManagementInformation::Presenter do
  subject(:presenter) { described_class.new(record) }

  # OPTIMIZE: to use factory build instead of create and hash the claim object instead
  # of querying the database. This would speed the tests up at the cost of being a less
  # realistic test.
  #
  let(:query) { Stats::ManagementInformation::DailyReportQuery.call }

  describe '#submission_type' do
    subject { presenter.submission_type }

    before { create(:litigator_final_claim, :authorised).tap(&:redetermine!) }

    context 'when first journey transition is submitted' do
      let(:record) { query.first }

      it { is_expected.to eq('new') }
    end

    context 'when first journey transition is redetermination' do
      let(:record) { query.last }

      it { is_expected.to eq('redetermination') }
    end
  end

  describe '#claim_total' do
    subject { presenter.claim_total }

    before do
      create(:litigator_final_claim, :submitted).tap do |c|
        c.update!(total: 9999.98555)
      end
    end

    let(:record) { query.first }

    it 'returns decimal rounded to 4 and kernel formatted to 2 decimal places' do
      is_expected.to eql('9999.99')
    end
  end

  describe '#transitioned_at' do
    subject { presenter.transitioned_at }

    let(:record) { query.first }

    context 'when journey contains no submissions (within 6 month cut off)' do
      before do
        travel_to(6.months.ago.beginning_of_day - 1.second) { claim }
        claim.allocate!
      end

      let(:claim) { create(:litigator_final_claim, :submitted) }

      it { is_expected.to eq('n/a') }
    end

    context 'when journey contains one or more submissions' do
      before { create(:litigator_final_claim, :allocated) }

      it { is_expected.to match(%r{\d{2}/\d{2}/\d{4}}) }
    end
  end

  describe '#last_submitted_at' do
    subject { presenter.last_submitted_at }

    before { create(:litigator_final_claim, :submitted) }

    let(:record) { query.first }

    it { is_expected.to match(%r{\d{2}/\d{2}/\d{4}}) }

    context 'with no last_submitted_at on record' do
      before do
        allow(record).to receive(:[])
          .with(:last_submitted_at).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#originally_submitted_at' do
    subject { presenter.originally_submitted_at }

    before { create(:litigator_final_claim, :submitted) }

    let(:record) { query.first }

    it { is_expected.to match(%r{\d{2}/\d{2}/\d{4}}) }

    context 'with no original_submission_date on record' do
      before do
        allow(record).to receive(:[])
          .with(:originally_submitted_at).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#allocated_at' do
    subject { presenter.allocated_at }

    context 'with allocated claim journey' do
      before { create(:advocate_final_claim, :allocated) }

      let(:record) { query.first }

      let(:allocated_at) do
        record[:journey].find { |j| j[:to].eql?('allocated') }[:created_at]
      end

      it { is_expected.to eql(allocated_at.strftime('%d/%m/%Y')) }
    end

    context 'with unallocated claim journey' do
      before { create(:advocate_final_claim, :submitted) }

      let(:record) { query.first }

      it { is_expected.to eql('n/a') }
    end

    # we have to find the last due to edge case of "stuck" claims that have been "unstuck".
    # such claims may have been [allocated, submitted, allocated, ...] so we want the last.
    context 'with an "unstuck" claim' do
      before do
        travel_to(1.day.ago) { stuck_claim }
        stuck_claim.allocate!
      end

      let(:stuck_claim) { create(:advocate_final_claim, :allocated).tap(&:submit!) }

      let(:record) { query.first }

      let(:allocated_ats) do
        record[:journey].find_all { |j| j[:to].eql?('allocated') }
      end

      it { is_expected.to eql(allocated_ats.last[:created_at].strftime('%d/%m/%Y')) }
    end
  end

  describe '#completed_at' do
    subject { presenter.completed_at }

    context 'with completed claim journey' do
      before { create(:advocate_final_claim, :authorised) }

      let(:record) { query.first }

      it { is_expected.to match(%r{(\d{2}/\d{2}/\d{4} \d{2}:\d{2})}) }
    end

    context 'with incomplete claim journey' do
      before { create(:advocate_final_claim, :allocated) }

      let(:record) { query.first }

      it { is_expected.to eql('n/a') }
    end
  end

  describe '#current_or_end_state' do
    subject { presenter.current_or_end_state }

    context 'with claim journey ending in submitted state' do
      before { create(:advocate_final_claim, :submitted) }

      let(:record) { query.last }

      it { is_expected.to eql('submitted') }
    end

    context 'with claim journey ending in redetermination state' do
      before { create(:advocate_final_claim, :refused).tap(&:redetermine!) }

      let(:record) { query.last }

      it { is_expected.to eql('submitted') }
    end

    context 'with claim journey ending in awaiting_written_reasons state' do
      before { create(:advocate_final_claim, :refused).tap(&:await_written_reasons!) }

      let(:record) { query.last }

      it { is_expected.to eql('submitted') }
    end

    context 'with claim journey ending in non-submission state' do
      before { create(:advocate_final_claim, :refused) }

      let(:record) { query.last }

      it { is_expected.to eql('refused') }
    end
  end

  describe '#state_reason_code' do
    subject { presenter.state_reason_code }

    before do
      create(:advocate_final_claim, :allocated).tap do |c|
        c.reject!(options)
      end
    end

    context 'with claim journey ending in transition with no reason' do
      let(:options) { {} }
      let(:record) { query.first }

      it { is_expected.to be_nil }
    end

    context 'with claim journey ending in transition with reason' do
      let(:options) { { reason_code: ['reason'] } }
      let(:record) { query.first }

      it { is_expected.to eql('reason') }
    end

    context 'with claim journey ending in transition with array of reasons' do
      let(:options) { { reason_code: %w[reason1 reason2] } }
      let(:record) { query.first }

      it { is_expected.to eql('reason1, reason2') }
    end
  end

  describe '#rejection_reason' do
    subject { presenter.rejection_reason }

    before do
      create(:advocate_final_claim, :allocated).tap do |c|
        c.reject!(options)
      end
    end

    context 'with claim journey ending in transition with no reason' do
      let(:options) { {} }
      let(:record) { query.first }

      it { is_expected.to be_nil }
    end

    context 'with claim journey ending in transition with reason' do
      let(:options) { { reason_code: ['reason'], reason_text: 'reason text from caseworker' } }
      let(:record) { query.first }

      it { is_expected.to eql('reason text from caseworker') }
    end
  end

  describe '#case_worker' do
    subject { presenter.case_worker }

    context 'with claim journey ending in allocated state' do
      let!(:claim) { create(:advocate_final_claim, :allocated) }
      let(:record) { query.first }

      it { is_expected.to eq claim.claim_state_transitions.find_by(to: 'allocated').subject.name }
    end

    context 'with claim journey ending in "completed" state' do
      let!(:claim) { create(:advocate_final_claim, :rejected) }
      let(:record) { query.first }

      it { is_expected.to eq claim.claim_state_transitions.find_by(to: 'rejected').author.name }
    end

    context 'with claim journey not ending in "completed" or allocated state' do
      before { create(:advocate_final_claim, :redetermination) }

      let(:record) { query.second }

      it { is_expected.to eq 'n/a' }
    end
  end

  describe '#disk_evidence_case' do
    subject { presenter.disk_evidence_case }

    let(:record) { query.first }

    context 'with claim with disk evidence' do
      before { create(:advocate_final_claim, :allocated, disk_evidence: true) }

      let(:record) { query.first }

      it { is_expected.to eql('Yes') }
    end

    context 'with claim without disk evidence' do
      before { create(:advocate_final_claim, :rejected, disk_evidence: false) }

      it { is_expected.to eql('No') }
    end
  end

  describe '#rep_order_issued_date' do
    subject { presenter.rep_order_issued_date }

    before { create(:advocate_final_claim, :allocated) }

    let(:record) { query.first }

    it { is_expected.to eql(record[:rep_order_issued_date].strftime('%d/%m/%Y')) }
  end

  describe '#main_hearing_date' do
    subject { presenter.main_hearing_date }

    before { create(:advocate_final_claim, :allocated, main_hearing_date: Date.new(2023, 2, 23)) }

    let(:record) { query.first }

    it { is_expected.to eql(record[:main_hearing_date].strftime('%d/%m/%Y')) }
  end

  describe '#method_missing' do
    before { create(:advocate_final_claim, :allocated) }

    let(:record) { query.first }

    let(:expected_missing_methods) do
      %i[id scheme case_number supplier_number
         organisation case_type_name bill_type
         main_defendant maat_reference
         af1_lf1_processed_by misc_fees]
    end

    it {
      expect(presenter).to respond_to(*expected_missing_methods)
    }
  end
end
