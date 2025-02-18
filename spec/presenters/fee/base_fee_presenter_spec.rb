require 'rails_helper'

RSpec.describe Fee::BaseFeePresenter do
  let(:claim)     { create(:advocate_claim) }
  let(:fee_type)  { create(:basic_fee_type, description: 'Basic fee type C') }
  let(:fee)       { create(:basic_fee, quantity: 4, claim:, fee_type:) }
  let(:presenter) { Fee::BaseFeePresenter.new(fee, view) }

  describe '#dates_attended_delimited_string' do
    before {
      claim.fees.each do |fee|
        fee.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('21/05/2014'), date_to: Date.parse('23/05/2014'))
        fee.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('25/05/2014'), date_to: nil)
      end
    }

    it 'outputs string of dates or date ranges separated by comma' do
      claim.fees.each do |fee|
        fee = Fee::BaseFeePresenter.new(fee, view)
        expect(fee.dates_attended_delimited_string).to eql('21/05/2014 - 23/05/2014, 25/05/2014')
      end
    end
  end

  describe '#quantity' do
    context 'when quantity allows a decimal' do
      before do
        allow(fee).to receive(:quantity_is_decimal?).and_return(true)
        fee.claim.force_validation = true
      end

      it 'returns a rounded decimal string' do
        fee.quantity = 54.769
        fee.validate
        expect(presenter.quantity).to eq '54.77'
      end
    end

    context 'when quantity does not allow a decimal' do
      before do
        allow(fee).to receive(:quantity_is_decimal?).and_return(false)
        fee.claim.force_validation = true
      end

      context 'with integer value' do
        it 'returns an integer string' do
          fee.quantity = 4.0
          fee.validate
          expect(presenter.quantity).to eq '4'
        end
      end

      context 'with decimal value' do
        it 'returns the erroneous decimal string' do
          fee.quantity = 3.45
          fee.validate
          expect(presenter.quantity).to eq '3.45'
        end
      end
    end
  end

  describe '#amount' do
    it 'formats as currency' do
      fee.amount = 32456.3
      expect(presenter.amount).to eq '£32,456.30'
    end
  end

  describe '#date' do
    it 'formats as date' do
      fee.date = Date.parse('21/05/2014')
      expect(presenter.date).to eq '21/05/2014'
    end

    it 'returns nil if date attribute is nil' do
      expect(presenter.date).to be_nil
    end
  end

  describe '#rate' do
    context 'calculated fees' do
      it 'rounds to 2 decimal places in string format' do
        fee.rate = 12.505
        expect(presenter.rate).to eq '£12.51'
      end
    end

    context 'for uncalculated fees' do
      it 'outputs placeholder html indicating rate is not applicable' do
        fee.rate = nil
        fee.fee_type.calculated = false
        expect(presenter.rate).to eq '<div class="form-hint">n/a</div>'
      end
    end
  end

  describe '#section_header' do
    context 'NOT PPE and NPW fees' do
      it 'outputs fee type description' do
        expect(presenter.section_header(nil)).to eq 'Basic fee type C'
      end
    end

    context 'PPE and NPW fees' do
      it 'outputs header' do
        allow(I18n).to receive(:t).and_return('header_text')
        fee.fee_type.code = 'PPE'
        expect(presenter.section_header('scope.for.translation')).to eq 'header_text'
      end

      it 'outputs hint' do
        allow(I18n).to receive(:t).and_return('hint_text')
        fee.fee_type.code = 'PPE'
        expect(presenter.section_hint('scope.for.translation')).to eq 'hint_text'
      end
    end
  end

  describe '#display_amount?' do
    subject(:display_amount?) { presenter.display_amount? }

    it { is_expected.to be_truthy }
  end

  describe '#days_claimed' do
    subject(:days_claimed) { presenter.days_claimed }

    it 'sends message #not_applicable' do
      expect(presenter).to receive(:not_applicable)
      days_claimed
    end
  end
end
