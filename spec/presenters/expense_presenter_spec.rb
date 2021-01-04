require 'rails_helper'

RSpec.describe ExpensePresenter do
  let(:claim) { create(:advocate_claim) }
  let(:expense_type) { create(:expense_type) }
  let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type) }

  subject(:presenter) { described_class.new(expense, view) }

  describe '#dates_attended_delimited_string' do
    before {
      claim.expenses.each do |fee|
        expense.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('21/05/2015'), date_to: Date.parse('23/05/2015'))
        expense.dates_attended << create(:date_attended, attended_item: fee, date: Date.parse('25/05/2015'), date_to: nil)
      end
    }

    it 'outputs string of dates or date ranges separated by comma' do
      claim.expenses.each do |fee|
        expense = ExpensePresenter.new(fee, view)
        expect(expense.dates_attended_delimited_string).to eql('21/05/2015 - 23/05/2015, 25/05/2015')
      end
    end
  end

  describe '#amount' do
    it 'formats as currency' do
      expense.amount = 32456.3
      expect(presenter.amount).to eq '£32,456.30'
    end
  end

  describe '#vat_amount' do
    it 'formats as currency' do
      expense.vat_amount = 1222.3
      expect(presenter.vat_amount).to eq '£1,222.30'
    end
  end

  describe '#total' do
    it 'formats as currency' do
      expense.amount = 32456.3
      expense.vat_amount = 1.3
      expect(presenter.total).to eq '£32,457.60'
    end
  end

  describe '#distance' do
    it 'formats as decimal number, 2 decimals precision, with rounding' do
      expense.distance = 324.479
      expect(presenter.distance).to eq '324.48'
    end

    it 'strips insignificant zeros' do
      expense.distance = 324.00
      expect(presenter.distance).to eq '324'
    end
  end

  describe '#calculated_distance' do
    let(:calculated_distance) { 234 }
    let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type, calculated_distance: calculated_distance) }

    it 'formats as decimal number, 2 decimals precision, with rounding' do
      expense.calculated_distance = 324.479
      expect(presenter.calculated_distance).to eq '324.48'
    end

    it 'strips insignificant zeros' do
      expense.calculated_distance = 324.00
      expect(presenter.calculated_distance).to eq '324'
    end

    context 'when is not set' do
      let(:calculated_distance) { nil }

      it { expect(presenter.calculated_distance).to be_nil }
    end
  end

  describe '#pretty_calculated_distance' do
    let(:calculated_distance) { 234 }
    let(:expense) { create(:expense, quantity: 4, claim: claim, expense_type: expense_type, calculated_distance: calculated_distance) }

    it 'returns the value with the locale unit' do
      expense.calculated_distance = 324.479
      expect(presenter.pretty_calculated_distance).to eq '324.48 miles'
    end

    context 'when is not set' do
      let(:calculated_distance) { nil }

      it { expect(presenter.pretty_calculated_distance).to eq('n/a') }
    end
  end

  describe '#hours' do
    it 'formats as decimal number, 2 decimals precision with rounding' do
      expense.hours = 35.239
      expect(presenter.hours).to eq '35.24'
    end

    it 'strips insignificant zeros' do
      expense.hours = 35.0
      expect(presenter.hours).to eq '35'
    end
  end

  describe '#name' do
    it 'outputs "Not selected" if there is no expense type' do
      expense.expense_type_id = nil
      expect(presenter.name).to eql('Not selected')
    end

    it 'outputs the type name is there is an expense type' do
      expense.expense_type_id = expense_type.id
      expect(presenter.name).to eql(expense.expense_type.name)
    end
  end

  describe '#display_reason_text_css' do
    def reason_requiring_text
      ExpenseType::REASON_SET_A.map { |reason| reason[1] if reason[1].allow_explanatory_text? }.compact.sample
    end

    it 'should return "none" for expense reasons NOT requiring explanantory' do
      expect(presenter.display_reason_text_css).to eql 'none'
    end

    it 'should return "inline-block" for expense reasons requiring explanantory text' do
      expense.reason_id = reason_requiring_text.id
      expect(presenter.display_reason_text_css).to eql 'inline-block'
    end
  end

  describe '#reason' do
    subject { presenter.reason }

    context 'when a specific reason was selected' do
      before do
        expense.reason_id = 1
      end

      it 'outputs the reason text' do
        is_expected.to eq('Court hearing')
      end
    end

    context 'when Other was selected' do
      before do
        expense.reason_id = 5
      end

      it 'outputs a placeholder text if no free text reason was provided' do
        is_expected.to eq('Not provided')
      end

      it 'outputs the free text reason if provided' do
        expense.reason_text = 'This is a test reason'
        is_expected.to eq('This is a test reason')
      end
    end
  end

  describe '#mileage_rate' do
    subject { presenter.mileage_rate }

    it 'outputs the mileage rate name if any' do
      expense.mileage_rate_id = 1
      is_expected.to eq('25p')
    end

    it 'outputs n/a if no mileage rate was selected' do
      expense.mileage_rate_id = nil
      is_expected.to eq('n/a')
    end
  end

  describe '#location_postcode' do
    subject { presenter.location_postcode }

    before do
      create(:establishment, :crown_court, name: 'Basildon', postcode: 'SS14 2EW')
    end

    context 'when a location exists' do
      let(:expense) { create(:expense, :car_travel, location: 'Basildon', claim: claim) }

      it 'returns the establishments postcode' do
        is_expected.to eql 'SS14 2EW'
      end
    end

    context 'when a location is NOT present' do
      let(:expense) { create(:expense, :parking, location: nil, claim: claim) }
      it { is_expected.to be_nil }
    end
  end

  describe '#location_with_postcode' do
    subject { presenter.location_with_postcode }

    before do
      create(:establishment, :prison, name: 'HMP Buckley Hall', postcode: 'OL12 9DP')
    end

    context 'when a location exists' do
      let(:expense) { create(:expense, :car_travel, location: 'HMP Buckley Hall', claim: claim) }

      it 'returns the establishment with postcode' do
        is_expected.to eql 'HMP Buckley Hall (OL12 9DP)'
      end
    end

    context 'when a location is NOT present' do
      let(:expense) { create(:expense, :parking, location: nil, claim: claim) }
      it { is_expected.to be_nil }
    end

    context 'when a locations establishment is NOT present' do
      let(:expense) { create(:expense, :parking, location: 'Timbuktu', claim: claim) }
      it { is_expected.to eql 'Timbuktu' }
    end
  end

  describe '#show_map_link?' do
    subject { presenter.show_map_link? }

    let(:claim) { create(:litigator_claim, :with_fixed_fee_case, :submitted, travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1)) }
    let(:expense) { create(:expense, :car_travel, calculated_distance: calculated_distance, mileage_rate_id: mileage_rate, location: 'Basildon', date: 3.days.ago, claim: claim) }
    let(:mileage_rate) { 1 }

    context 'when the mileage rate is 45p' do
      let(:mileage_rate) { 2 }

      { accepted: 27, decreased: 28, increased: 26 }.each do |type, value|
        context "and the distance is #{type}" do
          let(:calculated_distance) { value }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the mileage rate is 25p' do
      { accepted: 27, decreased: 28 }.each do |type, value|
        context "and the distance is #{type}" do
          let(:calculated_distance) { value }

          it { is_expected.to be false }
        end
      end

      context 'and the distance is increased' do
        let(:calculated_distance) { 26 }

        it { is_expected.to be true }
      end

      context 'and the calculated_distance is nil' do
        let(:calculated_distance) { nil }

        it { is_expected.to be false }
      end
    end
  end

  describe '#state' do
    subject { presenter.state }

    let(:claim) { create(:litigator_claim, :with_fixed_fee_case, :submitted, travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1)) }
    let(:expense) { create(:expense, :car_travel, calculated_distance: calculated_distance, mileage_rate_id: mileage_rate, location: 'Basildon', date: 3.days.ago, claim: claim) }
    let(:mileage_rate) { 1 }

    context 'when the expense has public standard mileage rate' do
      { accepted: { accepted: 27, decreased: 28 }, unverified: { increased: 26, nil: nil } }.each do |expected, values|
        values.each do |type, value|
          context "it #{type.eql?('nil') ? 'has not' : 'has'} been calculated and the distance is #{type}" do
            let(:calculated_distance) { value }

            it { is_expected.to eql expected.to_s.humanize }
          end
        end
      end
    end

    context 'when the expense has private mileage rate' do
      let(:mileage_rate) { 2 }
      { unverified: { accepted: 27, decreased: 28, increased: 26, nil: nil } }.each do |expected, values|
        values.each do |type, value|
          context "it #{type.eql?('nil') ? 'has not' : 'has'} been calculated and the distance is #{type}" do
            let(:calculated_distance) { value }

            it { is_expected.to eql expected.to_s.humanize }
          end
        end
      end
    end
  end

  describe '#distance_label' do
    subject { presenter.distance_label }

    let(:claim) { create(:litigator_claim, :with_fixed_fee_case, :submitted, travel_expense_additional_information: Faker::Lorem.paragraph(sentence_count: 1)) }
    let(:expense) { create(:expense, :car_travel, calculated_distance: calculated_distance, mileage_rate_id: mileage_rate, location: 'Basildon', date: 3.days.ago, claim: claim) }
    let(:mileage_rate) { 1 }

    context 'when the expense has public standard mileage rate' do
      context 'when the distance has been calculated' do
        context 'and has been accepted' do
          let(:calculated_distance) { 27 }

          it { is_expected.to eql '.distance' }
        end

        context 'and has been reduced' do
          let(:calculated_distance) { 28 }

          it { is_expected.to eql '.distance' }
        end

        context 'and has been increased' do
          let(:calculated_distance) { 26 }

          it { is_expected.to eql '.distance_claimed' }
        end
      end

      context 'when the distance has not been calculated' do
        let(:calculated_distance) { nil }

        it { is_expected.to eql '.distance_claimed' }
      end
    end

    context 'when the expense has private mileage rate' do
      let(:mileage_rate) { 2 }

      context 'when the distance has been calculated' do
        context 'and has been accepted' do
          let(:calculated_distance) { 27 }

          it { is_expected.to eql '.distance' }
        end

        context 'and has been reduced' do
          let(:calculated_distance) { 28 }

          it { is_expected.to eql '.distance' }
        end

        context 'and has been increased' do
          let(:calculated_distance) { 26 }

          it { is_expected.to eql '.distance_claimed' }
        end
      end

      context 'when the distance has not been calculated' do
        let(:calculated_distance) { nil }

        it { is_expected.to eql '.distance_claimed' }
      end
    end
  end
end
