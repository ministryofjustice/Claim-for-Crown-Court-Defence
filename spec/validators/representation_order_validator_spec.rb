require 'rails_helper'

RSpec.describe RepresentationOrderValidator, type: :validator do
  let(:claim)     { build(:claim) }
  let(:defendant) { build(:defendant, claim:) }
  let(:reporder)  { build(:representation_order, defendant:) }

  before do
    claim.force_validation = true
  end

  context 'representation_order_date' do
    it { should_error_if_not_present(reporder, :representation_order_date, 'Enter a representation order date') }
    it { should_error_if_in_future(reporder, :representation_order_date, 'Representation order date can not be too far in the future') }
    it { should_error_if_too_far_in_the_past(reporder, :representation_order_date, 'Representation orders should be entered in chronological order') }

    context 'for advocate final claims' do
      let(:case_type) { build(:case_type, :fixed_fee) }
      let(:claim) { build(:advocate_claim, case_type:) }

      context 'with a trial case type' do
        let(:first_day_of_trial) { 5.days.ago }
        let(:case_type) { build(:case_type, :trial) }
        let(:claim) { build(:advocate_claim, case_type:, first_day_of_trial:) }

        context 'and the representation order date is before the first day of trial' do
          let(:rep_order_date) { first_day_of_trial - 2.days }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date matches the first day of trial' do
          let(:rep_order_date) { first_day_of_trial }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date is later than the first day of trial' do
          let(:rep_order_date) { first_day_of_trial + 1.day }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          it 'is invalid' do
            expect(reporder).not_to be_valid
            expect(reporder.errors[:representation_order_date]).to include('Check combination of representation order date and trial dates')
          end
        end
      end

      context 'with a retrial case type' do
        let(:retrial_started_at) { 5.days.ago }
        let(:case_type) { build(:case_type, :retrial) }
        let(:claim) { build(:advocate_claim, case_type:, retrial_started_at:) }

        context 'and the representation order date is before the first day of retrial' do
          let(:rep_order_date) { retrial_started_at - 3.days }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date matches the first day of retrial' do
          let(:rep_order_date) { retrial_started_at }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date is later than the first day of retrial' do
          let(:rep_order_date) { retrial_started_at + 1.day }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          it 'is invalid' do
            expect(reporder).not_to be_valid
            expect(reporder.errors[:representation_order_date]).to include('Check combination of representation order date and trial dates')
          end
        end
      end

      context 'with a cracked trial case type' do
        let(:trial_cracked_at) { 5.days.ago }
        let(:case_type) { build(:case_type, :cracked_trial) }
        let(:claim) { build(:advocate_claim, case_type:, trial_cracked_at:) }

        context 'and the representation order date is before the trial cracked date' do
          let(:rep_order_date) { trial_cracked_at - 2.days }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date matches the trial cracked date' do
          let(:rep_order_date) { trial_cracked_at }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date is later than the first day of trial' do
          let(:rep_order_date) { trial_cracked_at + 1.day }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          it 'is invalid' do
            expect(reporder).not_to be_valid
            expect(reporder.errors[:representation_order_date]).to include('Check combination of representation order date and case cracked date')
          end
        end
      end

      context 'with a cracked before retrial case type' do
        let(:trial_cracked_at) { 5.days.ago }
        let(:case_type) { build(:case_type, :cracked_before_retrial) }
        let(:claim) { build(:advocate_claim, case_type:, trial_cracked_at:) }

        context 'and the representation order date is before the fixed notice date' do
          let(:rep_order_date) { trial_cracked_at - 2.days }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date matches the first day of trial' do
          let(:rep_order_date) { trial_cracked_at }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date is later than the first day of trial' do
          let(:rep_order_date) { trial_cracked_at + 1.day }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          it 'is invalid' do
            expect(reporder).not_to be_valid
            expect(reporder.errors[:representation_order_date]).to include('Check combination of representation order date and case cracked date')
          end
        end
      end
    end

    context 'for litigator final claims' do
      context 'when claim does not require case concluded date' do
        let(:case_concluded_at) { 5.days.ago }
        let(:claim) { build(:interim_claim, case_concluded_at:) }

        specify { expect(reporder).to be_valid }
      end

      context 'when claim requires case concluded date' do
        let(:case_concluded_at) { 5.days.ago }
        let(:claim) { build(:litigator_claim, case_concluded_at:) }

        context 'and the representation order date is before the case concluded date' do
          let(:rep_order_date) { case_concluded_at - 3.days }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date matches the case concluded date' do
          let(:rep_order_date) { case_concluded_at }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          specify { expect(reporder).to be_valid }
        end

        context 'and the representation order date is later than the case concluded date' do
          let(:rep_order_date) { case_concluded_at + 1.day }
          let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

          it 'is invalid' do
            expect(reporder).not_to be_valid
            expect(reporder.errors[:representation_order_date]).to include('Check combination of representation order date and case concluded date')
          end
        end
      end
    end

    context 'when future dates are allowed' do
      let(:reporder) { build(:representation_order, defendant:, representation_order_date: rep_order_date) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('ALLOW_FUTURE_DATES', nil).and_return('true')
        allow(ENV).to receive(:fetch).with('ENV', nil).and_return('dev')
      end

      context 'when a future date is entered' do
        let(:rep_order_date) { 2.days.from_now }

        it { expect(reporder).to be_valid }
      end

      context 'when a past date is entered' do
        let(:rep_order_date) { 2.days.ago }

        it { expect(reporder).to be_valid }
      end

      context 'when on the the production environment' do
        before do
          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with('ENV', nil).and_return('production')
        end

        context 'when a future date is entered' do
          let(:rep_order_date) { 2.days.from_now }

          it { expect(reporder).not_to be_valid }
        end

        context 'when a past date is entered' do
          let(:rep_order_date) { 2.days.ago }

          it { expect(reporder).to be_valid }
        end
      end
    end
  end

  context 'for a litigator interim claim' do
    let(:claim) { build(:interim_claim) }

    context 'representation_order_date' do
      let(:earliest_permitted_date) { Date.new(2014, 10, 2) }

      it { should_error_if_before_specified_date(reporder, :representation_order_date, earliest_permitted_date, 'Representation orders should be entered in chronological order') }
    end
  end

  context 'stand-alone rep order' do
    it 'is always valid if not attached to a defendant or claim' do
      reporder = build(:representation_order, defendant: nil, representation_order_date: nil)
      expect(reporder).to be_valid
    end
  end

  context 'multiple representation orders' do
    let(:claim) { create(:claim) }
    let(:first_rep_order) { claim.defendants.first.representation_orders.first }
    let(:last_rep_order) { claim.defendants.first.representation_orders.last }

    it 'is valid if the second reporder is dated after the first' do
      first_rep_order.update(representation_order_date: 2.weeks.ago)
      last_rep_order.update(representation_order_date: 1.day.ago)
      claim.force_validation = true
      expect(last_rep_order).to be_valid
    end

    it 'is invalid if second reporder dated before first' do
      pending 'The force_validation flag is not remaining set correctly during the tests as of Rails 7'

      last_rep_order.representation_order_date = first_rep_order.representation_order_date - 1.day
      claim.force_validation = true
      expect(last_rep_order).not_to be_valid
      expect(last_rep_order.errors[:representation_order_date])
        .to include('Representation orders should be entered in chronological order')
    end
  end
end
