RSpec.describe RepresentationOrder do
  subject(:representation_order) { build(:representation_order) }

  let(:claim) { build(:unpersisted_claim) }
  let(:defendant) { build(:defendant) }

  before do
    representation_order.defendant = defendant
    representation_order.defendant.claim = claim
    representation_order.defendant.claim.force_validation = true
  end

  context 'when validating maat_reference' do
    context 'when case type requires maat reference' do
      before do
        representation_order.defendant.claim.case_type = build(:case_type, :requires_maat_reference)
        representation_order.update(maat_reference:)
        representation_order.valid?
      end

      context 'with a blank maat_reference' do
        let(:maat_reference) { nil }

        it { is_expected.not_to be_valid }
        it { expect(representation_order.errors[:maat_reference]).to eq(['Enter a valid MAAT reference']) }
      end

      context 'with a maat_reference less than 7 numeric characters' do
        let(:maat_reference) { '456213' }

        it { is_expected.not_to be_valid }
        it { expect(representation_order.errors[:maat_reference]).to eq(['Enter a valid MAAT reference']) }
      end

      context 'with a maat_reference greater than 7 numeric characters' do
        let(:maat_reference) { '4562131111111' }

        it { is_expected.not_to be_valid }
        it { expect(representation_order.errors[:maat_reference]).to eq(['Enter a valid MAAT reference']) }
      end

      context 'with a maat_reference with non-numeric characters' do
        let(:maat_reference) { '1111a1111' }

        it { is_expected.not_to be_valid }
        it { expect(representation_order.errors[:maat_reference]).to eq(['Enter a valid MAAT reference']) }
      end

      context 'with a maat_reference with 7 numeric characters' do
        let(:maat_reference) { '5078332' }

        it { is_expected.to be_valid }
      end

      context 'with environment configured MAAT regex' do
        let(:maat_reference) { '2320006' }

        before { allow(Settings).to receive(:maat_regexp).and_return(/^[4-9][0-9]{6}$/) }

        it { is_expected.not_to be_valid }
      end

      context 'with no environment configured MAAT regex' do
        let(:maat_reference) { '2320006' }

        before { allow(Settings).to receive(:maat_regexp).and_call_original }

        it { is_expected.to be_valid }
      end

      context 'with the contingency maat_reference' do
        let(:maat_reference) { '900900' }

        it { is_expected.to be_valid }
      end
    end

    context 'when case type does not require maat_reference' do
      before do
        representation_order.defendant.claim.case_type = build(:case_type, requires_maat_reference: false)
        representation_order.update(maat_reference:)
        representation_order.valid?
      end

      context 'with a maat reference' do
        let(:maat_reference) { '2078352232' }

        it { is_expected.to be_valid }
      end

      context 'with no maat_reference' do
        let(:maat_reference) { nil }

        it { is_expected.to be_valid }
      end
    end
  end

  context 'with multiple reporders for the same defendant' do
    let(:claim) { create(:claim) }
    let(:first_rep_order) { claim.defendants.first.representation_orders.first }
    let(:other_rep_order) { claim.defendants.first.representation_orders.last }

    describe '#reporders_for_same_defendant' do
      let(:rep_orders) { first_rep_order.reporders_for_same_defendant }

      it { expect(rep_orders.size).to eq 2 }
      it { expect(rep_orders.map(&:class).uniq).to eq([described_class]) }
      it { expect(rep_orders.map(&:defendant_id).uniq).to eq([claim.defendants.first.id]) }
    end

    describe '#first_reporder_for_same_defendant' do
      it { expect(first_rep_order.first_reporder_for_same_defendant).to eq first_rep_order }
    end

    describe '#is_first_reporder_for_same_defendant?' do
      it { expect(first_rep_order.is_first_reporder_for_same_defendant?).to be true }
      it { expect(other_rep_order.is_first_reporder_for_same_defendant?).to be false }
    end
  end

  describe '#reporders_for_same_defendant' do
    let(:defendant) { create(:defendant, claim: Claim::AdvocateClaim.new) }
    let(:first_reporder) { create(:representation_order, defendant:) }
    let(:second_reporder) { create(:representation_order, defendant:) }

    it { expect(described_class.new.reporders_for_same_defendant).to eq([]) }
    it { expect(first_reporder.reporders_for_same_defendant).to match_array(defendant.representation_orders) }
    it { expect(second_reporder.reporders_for_same_defendant).to match_array(defendant.representation_orders) }
  end

  describe '#detail' do
    let(:date) { (Time.zone.today - 30.days).strftime('%d/%m/%Y') }
    let(:rep_order) { create(:representation_order, maat_reference: '1234567', representation_order_date: date) }

    context 'when rep order date present' do
      it { expect(rep_order.detail).to eq("#{date} 1234567") }
    end

    context 'when rep order date not present' do
      before { rep_order.representation_order_date = nil }

      it { expect(rep_order.detail).to eq('1234567') }
    end
  end
end
