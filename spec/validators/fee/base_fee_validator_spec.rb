require 'rails_helper'

RSpec.describe Fee::BaseFeeValidator, type: :validator do
  let(:claim) { build :advocate_claim, :with_fixed_fee_case }
  let(:fee) { build :fixed_fee, claim: claim }
  let(:baf_fee) { build :basic_fee, :baf_fee, claim: claim }
  let(:daf_fee) { build :basic_fee, :daf_fee, claim: claim }
  let(:dah_fee) { build :basic_fee, :dah_fee, claim: claim }
  let(:daj_fee) { build :basic_fee, :daj_fee, claim: claim }
  let(:dat_fee) { build :basic_fee, :dat_fee, claim: claim }
  let(:pcm_fee) { build :basic_fee, :pcm_fee, claim: claim }
  let(:ppe_fee) { build :basic_fee, :ppe_fee, claim: claim }
  let(:npw_fee) { build :basic_fee, :npw_fee, claim: claim }
  let(:spf_fee) { build :misc_fee, :spf_fee, claim: claim }
  let(:supplementary_claim) { build(:advocate_supplementary_claim) }
  let(:supplementary_pcm_fee) { build :basic_fee, :pcm_fee, claim: supplementary_claim }

  before do
    claim.force_validation = true
  end

  context 'for a JSON imported claim (and no forced validation)' do
    before do
      claim.force_validation = false
    end

    let(:claim) { build :advocate_claim, source: 'json_import' }

    it 'should not perform claim validation' do
      expect(claim.perform_validation?).to be_falsey
    end

    it 'should perform fee validation' do
      expect(ppe_fee.perform_validation?).to be_truthy
    end
  end

  describe '#validate_claim' do
    it { should_error_if_not_present(fee, :claim, 'blank') }
  end

  describe '#validate_fee_type' do
    shared_examples 'trial-fee-case-type validator' do |options|
      let(:claim) { build :advocate_claim, case_type: case_type }

      context 'with non trial case type' do
        context 'with guilty plea' do
          let(:case_type) { create(:case_type, :guilty_plea) }

          it { expect(fee).to be_invalid }
          it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }
          it {
            fee.valid?
            expect(fee.errors[:fee_type]).to include(options[:message])
          }
        end

        context 'with appeal against sentence' do
          let(:case_type) { create(:case_type, :appeal_against_sentence) }

          it { expect(fee).to be_invalid }
          it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }
          it {
            fee.valid?
            expect(fee.errors[:fee_type]).to include(options[:message])
          }
        end
      end

      context 'with trial fee case type' do
        let(:case_type) { create(:case_type, :trial) }

        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(0) }
      end

      context 'with nil case type' do
        let(:case_type) { nil }

        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(0) }
      end
    end

    let(:case_type) { create(:case_type, :graduated_fee) }

    it { should_error_if_not_present(fee, :fee_type, 'blank') }

    context 'when validating Unused material (upto 3 hours)' do
      before { create(:misc_fee_type, :miumu) }

      context 'with valid quantity' do
        let(:fee) { build(:misc_fee, :miumu_fee, claim: claim, quantity: 1) }

        it { expect { fee.valid? }.to change { fee.errors[:quantity].count }.by(0) }
      end

      context 'with invalid quantity' do
        let(:fee) { build(:misc_fee, :miumu_fee, claim: claim, quantity: 1.01) }

        it { expect(fee).to be_invalid }
        it { expect { fee.valid? }.to change { fee.errors[:quantity].count }.by(1) }
        it {
          fee.valid?
          expect(fee.errors[:quantity]).to include('miumu_numericality')
        }
      end

      it_behaves_like 'trial-fee-case-type validator', message: 'case_type_inclusion' do
        let(:fee) { build(:misc_fee, :miumu_fee, claim: claim, quantity: 1) }
      end
    end

    context 'when validating Unused material (over 3 hours)' do
      before { create(:misc_fee_type, :miumo) }

      context 'with valid quantity' do
        let(:fee) { build(:misc_fee, :miumo_fee, claim: claim, quantity: 0.01) }

        it { expect { fee.valid? }.to change { fee.errors[:quantity].count }.by(0) }
      end

      context 'with invalid quantity' do
        let(:fee) { build(:misc_fee, :miumo_fee, claim: claim, quantity: 0) }

        it { expect(fee).to be_invalid }
        it { expect { fee.valid? }.to change { fee.errors[:quantity].count }.by(1) }
        it {
          fee.valid?
          expect(fee.errors[:quantity]).to include('invalid')
        }
      end

      it_behaves_like 'trial-fee-case-type validator', message: 'case_type_inclusion' do
        let(:fee) { build(:misc_fee, :miumo_fee, claim: claim, quantity: 0.01) }
      end
    end

    context 'when validating Paper heavy case' do
      before { create(:misc_fee_type, :miphc) }

      let(:fee) { build(:misc_fee, :miphc_fee, claim: claim, quantity: 1.0) }
      let(:claim) { build(:advocate_claim, offence: offence) }
      let(:offence) { create(:offence, offence_band: offence_band, offence_class: nil) }
      let(:offence_band) { create(:offence_band, offence_category: offence_category) }
      let(:offence_category) { create(:offence_category, number: offence_category_number) }

      context 'with a nil offence band' do
        let(:offence_category_number) { nil }
        let(:offence) { create(:offence, offence_band: nil) }

        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(0) }
      end

      context 'with a nil offence category number' do
        let(:offence_category_number) { nil }

        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(0) }
      end

      context 'with a non-excluded offence category number' do
        let(:offence_category_number) { 2 }

        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(0) }
      end

      context 'with an excluded offence category number' do
        let(:offence_category_number) { 1 }

        it { expect(fee).to be_invalid }
        it { expect { fee.valid? }.to change { fee.errors[:fee_type].count }.by(1) }

        [1, 6, 9].each do |cat_number|
          context "with offence categeory #{cat_number}" do
            let(:offence_category_number) { cat_number }
            before { fee.valid? }

            it { expect(fee.errors[:fee_type]).to include('offence_category_exclusion') }
          end
        end
      end
    end
  end

  describe '#validate_date' do
    it { should_error_if_present(fee, :date, 3.days.ago, 'present') }
  end

  describe '#validate_warrant_issued_date' do
    it 'should raise error if date present' do
      fee.warrant_issued_date = Date.today
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_issued_date]).to eq(['present'])
    end
  end

  describe '#validate_warrant_executed_date' do
    it 'should raise error if date present' do
      fee.warrant_executed_date = Date.today
      expect(fee).not_to be_valid
      expect(fee.errors[:warrant_executed_date]).to eq(['present'])
    end
  end

  describe '#validate_rate' do
    let(:first_day_of_trial) { 1.month.ago }
    let(:actual_trial_length) { 10 }
    let(:trial_concluded_at) { first_day_of_trial + actual_trial_length.days }
    let(:case_type) { build(:case_type, :trial) }
    let(:claim) { build(:advocate_claim, case_type: case_type, actual_trial_length: actual_trial_length, first_day_of_trial: first_day_of_trial, trial_concluded_at: trial_concluded_at) }

    context 'with quantity greater than zero' do
      it { should_be_valid_if_equal_to_value(daf_fee, :rate, 450.00) }
      it { should_error_if_equal_to_value(baf_fee, :rate, 0.00, 'invalid') }
      it { should_error_if_equal_to_value(daf_fee, :rate, nil,  'invalid') }
      it { should_error_if_equal_to_value(daf_fee, :rate, 0.00, 'invalid') }
      it { should_error_if_equal_to_value(daf_fee, :rate, -320, 'invalid') }
    end

    context 'with quantity of zero and a rate greater than zero' do
      it 'BAF fee should raise BAF specific QUANTITY error' do
        baf_fee.quantity = 0
        expect(baf_fee.valid?).to be false
        expect(baf_fee.errors[:quantity]).to include('baf_invalid')
      end

      it 'DAF fee should raise DAF specific QUANTITY error' do
        daf_fee.quantity = 0
        expect(daf_fee.valid?).to be false
        expect(daf_fee.errors[:quantity]).to include('daf_invalid')
      end
    end

    context 'for fees on agfs draft claims' do
      it 'should validate presence of rate' do
        fee.amount = nil
        fee.rate = nil
        expect(fee).to_not be_valid
        expect(fee.errors.keys).to include(:rate)
        expect(fee.rate).to eq 0
        expect(fee.amount).to eq 0
      end
    end

    # NOTE: this enables fees that were created and submitted prior to rate being re-introduced to be valid
    context 'for fees on agfs submitted claims' do
      let(:claim) { build(:advocate_claim, :with_fixed_fee_case) }

      it 'should NOT validate presence of rate' do
        # TODO: there's some issues the factories related with the validity of its data
        # historically all claims were by default set with a form_step which is no longer
        # the case. Without it set, the claim as a whole is validated and other attributes
        # that are not set in the factories cause validation errors. Needs revisiting!
        fee.claim.form_step = :case_details
        fee.amount = 255
        fee.claim.submit!
        fee.rate = nil
        expect(fee).to be_valid
        expect(fee.rate).to eq 0
      end
    end

    # TODO: this will become default after production claims archived/deleted
    context 'for fees entered after rate was reintroduced' do
      it 'should require a rate of more than zero' do
        fee.amount = nil
        fee.rate = nil
        expect(fee).to_not be_valid
        expect(fee.rate).to eq 0
      end
    end

    context 'for uncalculated fees (PPE and NPW)' do
      it 'should raise an error when rate present' do
        [ppe_fee, npw_fee].each do |f|
          f.rate = 25
          expect(f).to_not be_valid
          expect(f.errors[:rate]).to include("#{f.fee_type.code.downcase}_must_be_blank")
        end
      end

      it 'should NOT raise an error when rate NOT present' do
        [ppe_fee, npw_fee].each do |f|
          f.rate = nil
          expect(f).to be_valid
        end
      end

      it 'should NOT raise an error when amount is zero and quantity is not' do
        [ppe_fee,npw_fee].each do |f|
          f.amount = 0
          expect(f).to be_valid
        end
      end
    end
  end

  describe '#validate_quantity' do
    context 'integer / decimal validation' do
      context 'integer' do
        it 'should allow integers' do
          npw_fee.quantity = 44
          expect(npw_fee).to be_valid
        end

        it 'should not allow decimals' do
          npw_fee.quantity = 34.57
          expect(npw_fee).not_to be_valid
          expect(npw_fee.errors[:quantity]).to eq(['integer'])
        end
      end

      context 'decimal' do
        it 'should allow integers' do
          spf_fee.quantity = 44
          expect(spf_fee).to be_valid
        end

        it 'should allow decimals' do
          spf_fee.quantity = 21.5
          expect(spf_fee).to be_valid
        end
      end
    end

    context 'Basic fee types' do
      let(:case_type) { build(:case_type, :trial) }
      let(:claim) { build(:advocate_claim, case_type: case_type) }

      context 'basic fee (BAF)' do
        context 'when rate present' do
          it 'should be valid with quantity of one' do
            should_be_valid_if_equal_to_value(baf_fee, :quantity, 1)
          end

          it 'should raise numericality error when quantity not in range 0 to 1' do
            [-1,2].each do |q|
              should_error_if_equal_to_value(baf_fee, :quantity, q, 'baf_qty_numericality')
            end
          end

          it 'should raise invalid error when quantity is nil or 0' do
            [nil,0].each do |q|
              should_error_if_equal_to_value(baf_fee, :quantity, q, 'baf_invalid')
            end
          end
        end

        context 'when rate NOT present' do
          before(:each) { baf_fee.rate = 0 }

          it 'should be valid when quantity is zero' do
            should_be_valid_if_equal_to_value(baf_fee, :quantity, 0)
          end

          it 'should raise invalid RATE error when quantity is one' do
            baf_fee.quantity = 1
            expect(baf_fee.valid?).to be false
            expect(baf_fee.errors[:rate]).to include('invalid')
          end
        end
      end

      context 'daily_attendance_3_40 (DAF)' do
        context 'trial length less than three days' do
          it 'should error if trial length is less than three days' do
            daf_fee.claim.actual_trial_length = 2
            should_error_if_equal_to_value(daf_fee, :quantity, 1, 'daf_qty_mismatch')
          end
        end

        context 'trial length greater than three days' do
          it 'should error if quantity greater than 38 regardless of actual trial length' do
            daf_fee.claim.actual_trial_length = 45
            should_error_if_equal_to_value(daf_fee, :quantity, 39, 'daf_qty_mismatch')
          end

          it 'should error if quantity greater than actual trial length less 2 days' do
            daf_fee.claim.actual_trial_length = 20
            should_error_if_equal_to_value(daf_fee, :quantity, 19, 'daf_qty_mismatch')
          end

          it 'should not error if quantity is valid' do
            daf_fee.claim.actual_trial_length = 20
            should_be_valid_if_equal_to_value(daf_fee, :quantity, 17)
            should_be_valid_if_equal_to_value(daf_fee, :quantity, 10)
          end
        end

        context 'for retrials' do
          let(:case_type) { build(:case_type, :retrial) }

          it 'should validate based on retrial length' do
            daf_fee.claim.actual_trial_length = 2
            daf_fee.claim.retrial_actual_length = 20
            should_be_valid_if_equal_to_value(daf_fee, :quantity, 18)
            should_error_if_equal_to_value(daf_fee, :quantity, 19, 'daf_qty_mismatch')
          end
        end
      end

      context 'daily_attendance_41_50 (DAH)' do
        it 'should error if trial length is less than 40 days' do
            dah_fee.claim.actual_trial_length = 35
            should_error_if_equal_to_value(dah_fee, :quantity, 2, 'dah_qty_mismatch')
        end

        context 'trial length greater than 40 days' do
          it 'should error if greater than trial length less 40 days' do
            dah_fee.claim.actual_trial_length = 45
            should_error_if_equal_to_value(dah_fee, :quantity, 6, 'dah_qty_mismatch')
          end

          it 'should error if greater than 10 days regardless of actual trial length' do
            dah_fee.claim.actual_trial_length = 70
            should_error_if_equal_to_value(dah_fee, :quantity, 12, 'dah_qty_mismatch')
          end

          it 'should not error if valid' do
            dah_fee.claim.actual_trial_length = 55
            should_be_valid_if_equal_to_value(dah_fee, :quantity, 1)
            should_be_valid_if_equal_to_value(dah_fee, :quantity, 10)
          end
        end

        it 'should validate based on retrial length for retrials' do
            dah_fee.claim.case_type = FactoryBot.create(:case_type, :retrial)
            dah_fee.claim.actual_trial_length = 2
            dah_fee.claim.retrial_actual_length = 45
            should_be_valid_if_equal_to_value(dah_fee, :quantity, 5)
            should_error_if_equal_to_value(dah_fee, :quantity, 6, 'dah_qty_mismatch')
        end
      end

      context 'daily attendance 51 plus (DAJ)' do
        context 'trial length less than 51 days' do
          it 'should error if trial length is less than 51 days' do
            daj_fee.claim.actual_trial_length = 50
            should_error_if_equal_to_value(daj_fee, :quantity, 2, 'daj_qty_mismatch')
          end
        end

        context 'trial length greater than 50 days' do
          it 'should error if greater than trial length less 50 days' do
            daj_fee.claim.actual_trial_length = 55
            should_error_if_equal_to_value(daj_fee, :quantity, 6, 'daj_qty_mismatch')
          end

          it 'should not error if valid' do
            daj_fee.claim.actual_trial_length = 60
            should_be_valid_if_equal_to_value(daj_fee, :quantity, 1)
            should_be_valid_if_equal_to_value(daj_fee, :quantity, 10)
          end
        end

        it 'should validate based on retrial length for retrials' do
            daj_fee.claim.case_type = FactoryBot.create(:case_type, :retrial)
            daj_fee.claim.actual_trial_length = 2
            daj_fee.claim.retrial_actual_length = 70
            should_be_valid_if_equal_to_value(daj_fee, :quantity, 20)
            should_error_if_equal_to_value(daj_fee, :quantity, 21, 'daj_qty_mismatch')
        end
      end

      context 'daily attendance 2 plus (DAT)' do
        context 'trial length less than 2 days' do
          let(:actual_trial_length) { 1 }

          it 'is not valid and cannot be claimed' do
            dat_fee.claim.actual_trial_length = 1
            should_error_if_equal_to_value(dat_fee, :quantity, 2, 'dat_qty_mismatch')
          end
        end

        context 'trial length was exactly 2 days' do
          let(:actual_trial_length) { 2 }

          context 'when the extra days claims are within the actual trial length' do
            it 'is valid and can be claimed' do
              dat_fee.claim.actual_trial_length = actual_trial_length
              should_be_valid_if_equal_to_value(dat_fee, :quantity, 1)
            end
          end

          context 'when the extra days claims are NOT within the actual trial length' do
            it 'is not valid and cannot be claimed' do
              dat_fee.claim.actual_trial_length = actual_trial_length
              should_error_if_equal_to_value(dat_fee, :quantity, 2, 'dat_qty_mismatch')
            end
          end
        end

        context 'trial length greater than 2 days' do
          let(:actual_trial_length) { 6 }

          context 'when the extra days claims are within the actual trial length' do
            it 'is valid and can be claimed' do
              dat_fee.claim.actual_trial_length = actual_trial_length
              should_be_valid_if_equal_to_value(dat_fee, :quantity, 5)
            end
          end

          context 'when the extra days claims are NOT within the actual trial length' do
            it 'is not valid and cannot be claimed' do
              dat_fee.claim.actual_trial_length = actual_trial_length
              should_error_if_equal_to_value(dat_fee, :quantity, 11, 'dat_qty_mismatch')
            end
          end
        end

        it 'should validate based on retrial length for retrials' do
          dat_fee.claim.case_type = create(:case_type, :retrial)
          dat_fee.claim.actual_trial_length = 2
          dat_fee.claim.retrial_actual_length = 10
          should_be_valid_if_equal_to_value(dat_fee, :quantity, 9)
          should_error_if_equal_to_value(dat_fee, :quantity, 10, 'dat_qty_mismatch')
        end
      end

      context 'plea and case management hearing (PCM)' do
        context 'permitted case type' do
          before(:each) do
            claim.case_type = FactoryBot.build :case_type, :allow_pcmh_fee_type
          end
          it { should_error_if_equal_to_value(pcm_fee, :quantity, 0, 'pcm_invalid') }
          it { should_error_if_equal_to_value(pcm_fee, :quantity, 4, 'pcm_numericality') }
          it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 3) }
          it { should_be_valid_if_equal_to_value(pcm_fee, :quantity, 1) }
        end

        context 'unpermitted case type' do
          before(:each) do
            claim.case_type = FactoryBot.build :case_type
          end
          it { should_error_if_equal_to_value(pcm_fee, :quantity, 1, 'pcm_not_applicable') }
          it { should_error_if_equal_to_value(pcm_fee, :quantity, -1, 'pcm_not_applicable') }
        end
      end

      context 'plea and case management hearing (PCM) for supplementary claims' do
        before(:each) do
          supplementary_claim.force_validation = true
        end
        it { should_error_if_equal_to_value(supplementary_pcm_fee, :quantity, 0, 'pcm_invalid') }
        it { should_error_if_equal_to_value(supplementary_pcm_fee, :quantity, 4, 'pcm_numericality') }
        it { should_be_valid_if_equal_to_value(supplementary_pcm_fee, :quantity, 3) }
        it { should_be_valid_if_equal_to_value(supplementary_pcm_fee, :quantity, 1) }
      end

      context 'number of cases uplift (BANOC)' do
        let(:noc_fee) { build :basic_fee, :noc_fee, claim: claim }
        include_examples 'common AGFS number of cases uplift validations'
      end
    end

    context 'Fixed fee types' do
      context 'number of cases uplift (FXNOC)' do
        let(:noc_fee) { build :fixed_fee, :fxnoc_fee, claim: claim }
        include_examples 'common AGFS number of cases uplift validations'
      end
    end

    context 'any other fee' do
      before { fee.rate = 1 }

      it { should_error_if_equal_to_value(fee, :quantity, -1, 'invalid') }
      it { should_be_valid_if_equal_to_value(fee, :quantity, 99999) }
      it { should_error_if_equal_to_value(fee, :quantity, 100000, 'invalid') }

      it 'should not allow zero if amount is not zero' do
        should_error_if_equal_to_value(fee, :quantity, 0, 'invalid')
      end

      it 'should error if resulting amount (rate * quantity) is greater than the max limit' do
        fee.fee_type.calculated = false
        fee.rate = 101
        fee.quantity = 2000
        fee.amount = 203000
        expect(fee).not_to be_valid
        expect(fee.errors[:amount]).not_to be_empty
      end
    end
  end

  describe '#validate_amount' do
    context 'uncalculated fee validate amount against quantity' do
      it 'should be valid if quantity greater than zero and amount is nil, zero or greater than zero' do
        should_be_valid_if_equal_to_value(ppe_fee, :amount, nil)
        should_be_valid_if_equal_to_value(ppe_fee, :amount, 0.00)
        should_be_valid_if_equal_to_value(ppe_fee, :amount, 350.00)
      end

      it 'should error if amount less than zero' do
        should_error_if_equal_to_value(ppe_fee, :amount, -200, 'ppe_invalid')
        should_error_if_equal_to_value(npw_fee, :amount, -200, 'npw_invalid')
      end

      it 'should error if amount is greater than the max limit' do
        should_error_if_equal_to_value(ppe_fee, :amount, 200_001, 'ppe_invalid')
        should_error_if_equal_to_value(npw_fee, :amount, 200_001, 'npw_invalid')
      end

      it 'should error if amount greater than zero and quantity is nil, zero or less than zero' do
        should_error_if_equal_to_value(ppe_fee, :quantity, 0, 'ppe_invalid')
        should_error_if_equal_to_value(ppe_fee, :quantity, nil, 'ppe_invalid')
        should_error_if_equal_to_value(ppe_fee, :quantity, -2, 'ppe_invalid')
        should_error_if_equal_to_value(npw_fee, :quantity, 0, 'npw_invalid')
        should_error_if_equal_to_value(npw_fee, :quantity, nil, 'npw_invalid')
        should_error_if_equal_to_value(npw_fee, :quantity, -2, 'npw_invalid')
      end
    end

    context 'calculated fees do NOT validate amount against quantity' do
      it 'should always be valid since amount is derived from rate * quantity' do
        should_be_valid_if_equal_to_value(baf_fee, :amount, nil)
        should_be_valid_if_equal_to_value(baf_fee, :amount, 0.00)
        should_be_valid_if_equal_to_value(baf_fee, :amount, 350.00)
      end
    end
  end
end
