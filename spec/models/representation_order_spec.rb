RSpec.describe RepresentationOrder do
  let(:claim) { build(:unpersisted_claim) }
  let(:defendant) { build(:defendant) }
  let(:representation_order) { build(:representation_order) }

  before do
    representation_order.defendant = defendant
    representation_order.defendant.claim = claim
    representation_order.defendant.claim.force_validation = true
  end

  context 'when validating maat_reference' do
    context 'when case type requires maat reference' do
      before do
        representation_order.defendant.claim.case_type = build(:case_type, :requires_maat_reference)
      end

      it 'should error if blank' do
        representation_order.maat_reference = nil
        expect(representation_order).not_to be_valid
        expect(representation_order.errors[:maat_reference]).to eq(['invalid'])
      end

      it 'should error if less than 7 numeric characters' do
        representation_order.maat_reference = '456213'
        expect(representation_order).not_to be_valid
        expect(representation_order.errors[:maat_reference]).to eq(['invalid'])
      end

      it 'should error if greater than 7 numeric characters' do
        representation_order.maat_reference = '4562131111111'
        expect(representation_order).not_to be_valid
        expect(representation_order.errors[:maat_reference]).to eq(['invalid'])
      end

      it 'should error if non-numeric characters present' do
        representation_order.maat_reference = '1111a1111'
        expect(representation_order).not_to be_valid
        expect(representation_order.errors[:maat_reference]).to eq(['invalid'])
      end

      it 'should not error if 7 numeric digits' do
        representation_order.maat_reference = '5078332'
        expect(representation_order).to be_valid
      end

      context 'with a test MAAT reference' do
        before { representation_order.maat_reference = '2320006' }

        context 'with environment configured MAAT regex' do
          before do
            allow(Settings).to receive(:maat_regexp).and_return /^[4-9][0-9]{6}$/
          end

          it 'should error' do
            expect(representation_order).not_to be_valid
          end
        end

        context 'with no environment configured MAAT regex' do
          before do
            allow(Settings).to receive(:maat_regexp).and_call_original
          end

          it 'should be valid' do
            expect(representation_order).to be_valid
          end
        end
      end
    end

    context 'when case type does not require maat reference' do
      before do
        representation_order.defendant.claim.case_type = build(:case_type, requires_maat_reference: false)
      end

      it 'should not error if present' do
        representation_order.maat_reference = '2078352232'
        expect(representation_order).to be_valid
      end

      it 'should not error if absent' do
        representation_order.maat_reference = nil
        expect(representation_order).to be_valid
      end
    end
  end

  context 'reporders for same defendant methods' do
    let(:claim) { create(:claim) }
    let(:ro1) { claim.defendants.first.representation_orders.first }
    let(:ro2) { claim.defendants.first.representation_orders.last }

    describe '#reporders_for_same_defendant' do
      it 'should return an array of representation orders' do
        rep_orders = ro1.reporders_for_same_defendant
        expect(rep_orders.size).to eq 2
        expect(rep_orders.map(&:class).uniq).to eq([RepresentationOrder])
        expect(rep_orders.map(&:defendant_id).uniq).to eq([claim.defendants.first.id])
      end
    end

    describe '#first_reporder_for_same_defendant' do
      it 'should return the first reporder for the same defendant' do
        expect(ro1.first_reporder_for_same_defendant).to eq ro1
      end
    end

    describe '#is_first_reporder_for_same_defendant?' do
      it 'should be true for the first reporder' do
        expect(ro1.is_first_reporder_for_same_defendant?).to be true
      end

      it 'should be false for other reporders' do
        expect(ro2.is_first_reporder_for_same_defendant?).to be false
      end
    end
  end

  describe '#reporders_for_same_defendant' do
    it 'returns empty array if reporder not completely set up' do
      expect(RepresentationOrder.new.reporders_for_same_defendant).to eq ( [])
    end

    it 'returns an aray of all reporders including this for the same defendant' do
      defendant = create :defendant, claim: Claim::AdvocateClaim.new
      create :representation_order, defendant: defendant
      reporder_2 = create :representation_order, defendant: defendant
      defendant.reload
      expect(reporder_2.reporders_for_same_defendant).to match_array(defendant.representation_orders)
    end
  end

  describe '#detail' do
    let(:rep_order) do
      create(:representation_order, maat_reference: '1234567', representation_order_date: Date.parse('20150925'))
    end

    context 'when rep order date present' do
      it 'returns a string with the MAAT reference and rep order date' do
        expect(rep_order.detail).to eq('25/09/2015 1234567')
      end
    end

    context 'when rep order date not present' do
      before do
        rep_order.representation_order_date = nil
      end

      it 'returns a string with the MAAT reference' do
        expect(rep_order.detail).to eq('1234567')
      end
    end
  end
end
