RSpec.shared_examples 'a successful daily attendance fee calculation' do
  context 'daily attendance fees' do
    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      context 'for a daily attendance (3 to 40)' do
        let(:fee_type) { create(:basic_fee_type, :daf) }
        let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 530.00
      end

      context 'for a daily attendance (41 to 50)' do
        let(:fee_type) { create(:basic_fee_type, :dah) }
        let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 266.00
      end

      context 'for a daily attendance (51+)' do
        let(:fee_type) { create(:basic_fee_type, :daj) }
        let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 285.00
      end
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      context 'for a daily attendance (2+)' do
        let(:fee_type) { create(:basic_fee_type, :dat) }
        let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

        it_returns 'a successful fee calculator response', unit: 'day', amount: 300.00
      end
    end
  end
end

RSpec.shared_examples 'a failed daily attendance fee calculation' do |options = {}|
  context 'daily attendance fees' do
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      context 'for a daily attendance (3 to 40)' do
        let(:fee_type) { create(:basic_fee_type, :daf) }

        it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
      end

      context 'for a daily attendance (41 to 50)' do
        let(:fee_type) { create(:basic_fee_type, :dah) }

        it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
      end

      context 'for a daily attendance (51+)' do
        let(:fee_type) { create(:basic_fee_type, :daj) }

        it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
      end
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      context 'for a daily attendance (2+)' do
        let(:fee_type) { create(:basic_fee_type, :dat) }
        let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

        it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
      end
    end
  end
end

RSpec.shared_examples 'a successful standard appearance fee calculation' do
  context 'for a standard appearance fee' do
    let(:fee_type) { create(:basic_fee_type, :basaf) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a successful fee calculator response', unit: 'day', amount: 87.00
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a successful fee calculator response', unit: 'day', amount: 90.00
    end
  end
end

RSpec.shared_examples 'a failed standard appearance fee calculation' do |options = {}|
  context 'for a standard appearance fee' do
    let(:fee_type) { create(:basic_fee_type, :basaf) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end
  end
end

RSpec.shared_examples 'a successful plea and trial preparation fee calculation' do
  context 'for a plea and trial preparation fee' do
    let(:fee_type) { create(:basic_fee_type, :bapcm) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a successful fee calculator response', unit: 'case', amount: 87.00
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a successful fee calculator response', unit: 'case', amount: 125.00
    end
  end
end

RSpec.shared_examples 'a failed plea and trial preparation fee calculation' do |options = {}|
  context 'for a plea and trial preparation fee' do
    let(:fee_type) { create(:basic_fee_type, :bapcm) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end
  end
end

RSpec.shared_examples 'a successful conferences and views fee calculation' do
  context 'for a conferences and views fee' do
    let(:fee_type) { create(:basic_fee_type, :bacav) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a successful fee calculator response', unit: 'hour', amount: 39.00
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a successful fee calculator response', unit: 'hour', amount: 40.00
    end
  end
end

RSpec.shared_examples 'a failed conferences and views fee calculation' do |options = {}|
  context 'for a conferences and views fee' do
    let(:fee_type) { create(:basic_fee_type, :bacav) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end
  end
end

RSpec.shared_examples 'a successful basic uplift fee calculation' do |options = {}|
  context "for a #{options[:unit]} uplift fee" do
    let(:fee_type) { create(:basic_fee_type, :babaf) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }
    let(:uplift_fee_type) { create(:basic_fee_type, options.fetch(:uplift_fee_type)) }
    let(:uplift_fee) { create(:basic_fee, fee_type: uplift_fee_type, quantity: 1) }

    before do
      params[:fee_type_id] = uplift_fee.fee_type.id
      params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
    end

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a successful fee calculator response', unit: options.fetch(:unit), amount: options.fetch(:scheme_9_amount, 326.40)
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a successful fee calculator response', unit: options.fetch(:unit), amount: options.fetch(:scheme_10_amount, 110.00)
    end
  end
end

RSpec.shared_examples 'a failed basic uplift fee calculation' do |options = {}|
  context "for a #{options[:description]} uplift fee" do
    let(:fee_type) { create(:basic_fee_type, :babaf) }
    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }
    let(:uplift_fee_type) { create(:basic_fee_type, options.fetch(:uplift_fee_type)) }
    let(:uplift_fee) { create(:basic_fee, fee_type: uplift_fee_type, quantity: 1) }

    before do
      params[:fee_type_id] = uplift_fee.fee_type.id
      params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
    end

    context 'scheme 9' do
      let(:claim) { scheme_9_claim }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end

    context 'scheme 10' do
      let(:claim) { scheme_10_claim }

      before { params.merge!(advocate_category: 'Junior') }

      it_returns 'a failed fee calculator response', message: options.fetch(:message, /insufficient_data/i)
    end
  end
end

RSpec.describe Claims::FeeCalculator::UnitPrice, :fee_calc_vcr do
  subject { described_class.new(claim, {}) }

  # IMPORTANT: use specific case type, offence class, fee types and reporder
  # date in order to reduce and afix VCR cassettes required (that have to match
  # on query values), prevent flickering specs (from random offence classes,
  # rep order dates) and to allow testing actual amounts "calculated".
  let(:case_type) { create(:case_type, :appeal_against_conviction) }

  let(:offence_class) { create(:offence_class, class_letter: 'K') }
  let(:scheme_9_offence) { create(:offence, :with_fee_scheme_nine, offence_class:) }
  let(:scheme_9_claim) { create(:draft_claim, case_type:, offence: scheme_9_offence, create_defendant_and_rep_order_for_scheme_9: true) }

  let(:offence_band) { create(:offence_band, :for_standard) }
  let(:scheme_10_offence) { create(:offence, :with_fee_scheme_ten, offence_band:) }
  let(:scheme_10_claim) { create(:draft_claim, case_type:, offence: scheme_10_offence, create_defendant_and_rep_order_for_scheme_10: true) }

  let(:fee_type) { create(:fixed_fee_type, :fxacv) }
  let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

  let(:claim) { build(:draft_claim) }

  it { is_expected.to respond_to(:call) }

  before(:all) { seed_fee_schemes }

  after(:all) { clean_database }

  context 'AGFS claims' do
    describe '#call' do
      subject(:response) { described_class.new(claim, params).call }

      let(:claim) { scheme_9_claim }

      let(:params) do
        {
          advocate_category: 'Junior alone',
          fee_type_id: fee.fee_type.id,
          fees: {
            '0': { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      context 'basic fees' do
        context 'trial' do
          let(:case_type) { create(:case_type, :trial) }

          include_examples 'a successful daily attendance fee calculation'
          include_examples 'a successful standard appearance fee calculation'
          include_examples 'a successful plea and trial preparation fee calculation'
          include_examples 'a successful conferences and views fee calculation'
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant'
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case'
        end

        context 'retrial' do
          let(:case_type) { create(:case_type, :retrial) }

          include_examples 'a successful standard appearance fee calculation'
          include_examples 'a successful plea and trial preparation fee calculation'
          include_examples 'a successful conferences and views fee calculation'

          context 'with retrial interval of negative calendar month' do
            before do
              trial_end = 3.months.ago.to_date
              retrial_start = trial_end - 6.months
              allow(claim).to receive(:trial_concluded_at).and_return trial_end
              allow(claim).to receive(:retrial_started_at).and_return retrial_start
            end

            context 'with retrial reduction requested' do
              before { allow(claim).to receive(:retrial_reduction).and_return true }

              include_examples 'a failed daily attendance fee calculation'
              include_examples 'a failed basic uplift fee calculation', description: 'defendant', uplift_fee_type: :bandr
              include_examples 'a failed basic uplift fee calculation', description: 'case', uplift_fee_type: :banoc
            end

            context 'without retrial reduction' do
              include_examples 'a successful daily attendance fee calculation'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case'
            end
          end

          context 'with retrial interval within one calendar month' do
            before do
              trial_end = 3.months.ago.to_date
              retrial_start = trial_end + 1.month
              allow(claim).to receive(:trial_concluded_at).and_return trial_end
              allow(claim).to receive(:retrial_started_at).and_return retrial_start
            end

            context 'with retrial reduction requested' do
              before { allow(claim).to receive(:retrial_reduction).and_return true }

              context 'daily attendance fees' do
                context 'scheme 9' do
                  let(:claim) { scheme_9_claim }

                  context 'for a daily attendance (3 to 40)' do
                    let(:fee_type) { create(:basic_fee_type, :daf) }
                    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

                    context '30% reduction applies' do
                      it_returns 'a successful fee calculator response', unit: 'day', amount: 371.00
                    end
                  end

                  context 'for a daily attendance (41 to 50)' do
                    let(:fee_type) { create(:basic_fee_type, :dah) }
                    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

                    context 'reduction does not apply (could be a bug in the API???)' do
                      it_returns 'a successful fee calculator response', unit: 'day', amount: 266.00
                    end
                  end
                end

                context 'scheme 10' do
                  let(:claim) { scheme_10_claim }

                  before { params.merge!(advocate_category: 'Junior') }

                  context 'for a daily attendance (2+)' do
                    let(:fee_type) { create(:basic_fee_type, :dat) }
                    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

                    context '30% reduction applies' do
                      it_returns 'a successful fee calculator response', unit: 'day', amount: 210.00
                    end
                  end
                end
              end

              context 'for a basic defendant uplift fee' do
                let(:fee_type) { create(:basic_fee_type, :babaf) }
                let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }
                let(:uplift_fee_type) { create(:basic_fee_type, :bandr) }
                let(:uplift_fee) { create(:basic_fee, fee_type: uplift_fee_type, quantity: 1) }

                before do
                  params[:fee_type_id] = uplift_fee.fee_type.id
                  params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
                end

                context 'scheme 9' do
                  let(:claim) { scheme_9_claim }

                  context '30% reduction applies' do
                    it_returns 'a successful fee calculator response', unit: 'defendant', amount: 228.48
                  end
                end

                context 'scheme 10' do
                  let(:claim) { scheme_10_claim }

                  before { params.merge!(advocate_category: 'Junior') }

                  context '30% reduction applies' do
                    it_returns 'a successful fee calculator response', unit: 'defendant', amount: 77.00
                  end
                end
              end
            end

            context 'without retrial reduction' do
              include_examples 'a successful daily attendance fee calculation'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case'
            end
          end

          context 'with retrial interval greater than one calendar month' do
            before do
              trial_end = 3.months.ago.to_date
              retrial_start = trial_end + 1.month + 1.day
              allow(claim).to receive(:trial_concluded_at).and_return trial_end
              allow(claim).to receive(:retrial_started_at).and_return retrial_start
            end

            context 'with retrial reduction requested' do
              before { allow(claim).to receive(:retrial_reduction).and_return true }

              context 'daily attendance fees' do
                context 'scheme 9' do
                  let(:claim) { scheme_9_claim }

                  context 'for a daily attendance (3 to 40)' do
                    let(:fee_type) { create(:basic_fee_type, :daf) }
                    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

                    context '20% reduction applies' do
                      it_returns 'a successful fee calculator response', unit: 'day', amount: 424.00
                    end
                  end
                end

                context 'scheme 10' do
                  let(:claim) { scheme_10_claim }

                  before { params.merge!(advocate_category: 'Junior') }

                  context 'for a daily attendance (2+)' do
                    let(:fee_type) { create(:basic_fee_type, :dat) }
                    let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }

                    context '20% reduction applies' do
                      it_returns 'a successful fee calculator response', unit: 'day', amount: 240.00
                    end
                  end
                end
              end

              context 'for a basic defendant uplift fee' do
                let(:fee_type) { create(:basic_fee_type, :babaf) }
                let(:fee) { create(:basic_fee, fee_type:, claim:, quantity: 1) }
                let(:uplift_fee_type) { create(:basic_fee_type, :bandr) }
                let(:uplift_fee) { create(:basic_fee, fee_type: uplift_fee_type, quantity: 1) }

                before do
                  params[:fee_type_id] = uplift_fee.fee_type.id
                  params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
                end

                context 'scheme 9' do
                  let(:claim) { scheme_9_claim }

                  context '20% reduction applies' do
                    it_returns 'a successful fee calculator response', unit: 'defendant', amount: 261.12
                  end
                end

                context 'scheme 10' do
                  let(:claim) { scheme_10_claim }

                  before { params.merge!(advocate_category: 'Junior') }

                  context '20% reduction applies' do
                    it_returns 'a successful fee calculator response', unit: 'defendant', amount: 88.00
                  end
                end
              end
            end

            context 'without retrial reduction' do
              include_examples 'a successful daily attendance fee calculation'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant'
              include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case'
            end
          end
        end

        context 'guilty plea' do
          let(:case_type) { create(:case_type, :guilty_plea) }

          # guilty pleas daily attendances do not exist in API
          include_examples 'a failed daily attendance fee calculation', message: /price not found/i
          include_examples 'a successful standard appearance fee calculation'
          include_examples 'a successful plea and trial preparation fee calculation'
          include_examples 'a successful conferences and views fee calculation'
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant', scheme_9_amount: 195.80, scheme_10_amount: 55.00
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case', scheme_9_amount: 195.80, scheme_10_amount: 55.00
        end

        context 'discontinuance' do
          let(:case_type) { create(:case_type, :discontinuance) }

          # discontinuance daily attendances do not exist in API
          include_examples 'a failed daily attendance fee calculation', message: /price not found/i
          include_examples 'a successful standard appearance fee calculation'
          include_examples 'a successful plea and trial preparation fee calculation'
          include_examples 'a successful conferences and views fee calculation'
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant', scheme_9_amount: 195.80, scheme_10_amount: 55.00
          include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case', scheme_9_amount: 195.80, scheme_10_amount: 55.00
        end

        context 'cracked trial' do
          let(:case_type) { create(:case_type, :cracked_trial) }

          before do
            allow(claim).to receive(:trial_cracked_at_third).and_return 'first_third'
          end

          # cracked trial daily attendances do not exist in API
          include_examples 'a failed daily attendance fee calculation', message: /price not found/i
          include_examples 'a successful standard appearance fee calculation'
          include_examples 'a successful plea and trial preparation fee calculation'
          include_examples 'a successful conferences and views fee calculation'

          context 'cracked in first third' do
            before do
              allow(claim).to receive(:trial_cracked_at_third).and_return 'first_third'
            end

            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant', scheme_9_amount: 195.80, scheme_10_amount: 55.00
            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case', scheme_9_amount: 195.80, scheme_10_amount: 55.00
          end

          context 'cracked in second third' do
            before do
              allow(claim).to receive(:trial_cracked_at_third).and_return 'second_third'
            end

            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant', scheme_9_amount: 246.80, scheme_10_amount: 55.00
            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case', scheme_9_amount: 246.80, scheme_10_amount: 55.00
          end

          context 'cracked in final third' do
            before do
              allow(claim).to receive(:trial_cracked_at_third).and_return 'final_third'
            end

            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :bandr, unit: 'defendant', scheme_9_amount: 246.80, scheme_10_amount: 94.0
            include_examples 'a successful basic uplift fee calculation', uplift_fee_type: :banoc, unit: 'case', scheme_9_amount: 246.80, scheme_10_amount: 94.0
          end
        end

        context 'cracked before retrial' do
          let(:case_type) { create(:case_type, :cracked_before_retrial) }

          # cracked before retrial is excluded until we handle retrial reduction in app
          include_examples 'a failed daily attendance fee calculation'
          include_examples 'a failed standard appearance fee calculation'
          include_examples 'a failed plea and trial preparation fee calculation'
          include_examples 'a failed conferences and views fee calculation'
          include_examples 'a failed basic uplift fee calculation', description: 'defendant', uplift_fee_type: :bandr
          include_examples 'a failed basic uplift fee calculation', description: 'case', uplift_fee_type: :banoc
        end
      end

      context 'fixed fees' do
        let(:claim) { scheme_9_claim }
        let(:fee_type) { create(:fixed_fee_type, :fxacv) }
        let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

        context 'for a case-type-specific fixed fee' do
          it_returns 'a successful fee calculator response', unit: 'day', amount: 130.0
        end

        context 'for a case-type-specific fixed fee with fixed amount (elected case not proceeded)' do
          let(:case_type) { create(:case_type, :elected_cases_not_proceeded) }
          let(:fee_type) { create(:fixed_fee_type, :fxenp) }
          let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

          it_returns 'a successful fee calculator response', unit: 'day', amount: 194.0
        end

        context 'for a non-case-type-specific fixed fee (standard appearance fee/adjournments)' do
          let(:saf_fee) { create(:fixed_fee, :fxsaf_fee, claim:, quantity: 1) }

          before do
            params[:fee_type_id] = saf_fee.fee_type.id
            params[:fees].merge!('1': { fee_type_id: saf_fee.fee_type.id, quantity: saf_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'day', amount: 87.0
        end

        # TODO: deprecated fee type - to be removed
        context 'for a case-type-specific fixed fee case uplift' do
          let(:uplift_fee_type) { create(:fixed_fee_type, :fxacu) }
          let(:uplift_fee) { create(:fixed_fee, fee_type: uplift_fee_type, claim:, quantity: 1) }

          before do
            params[:fee_type_id] = uplift_fee.fee_type.id
            params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'case', amount: 26.0
        end

        context 'for a fixed fee number of cases uplift' do
          let(:uplift_fee_type) { create(:fixed_fee_type, :fxnoc) }
          let(:uplift_fee) { create(:fixed_fee, fee_type: uplift_fee_type, claim:, quantity: 1) }

          before do
            params[:fee_type_id] = uplift_fee.fee_type.id
            params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'case', amount: 26.0
        end

        context 'for a fixed fee number of defendants uplift' do
          let(:uplift_fee_type) { create(:fixed_fee_type, :fxndr) }
          let(:uplift_fee) { create(:fixed_fee, fee_type: uplift_fee_type, claim:, quantity: 1) }

          before do
            params[:fee_type_id] = uplift_fee.fee_type.id
            params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'defendant', amount: 26.0
        end
      end

      context 'miscellaneous fees' do
        context 'for non-(defendant)-uplift misc fees' do
          let(:fee) { create(:misc_fee, :miaph_fee, claim:, quantity: 1) }

          context 'on claims with a case type' do
            it_returns 'a successful fee calculator response', unit: 'halfday', amount: 130.0
          end

          context 'on (supplementary) claims with no case type' do
            before do
              claim.case_type = nil
              allow(claim).to receive(:supplementary?).and_return true
            end

            it_returns 'a successful fee calculator response', unit: 'halfday', amount: 130.0
          end
        end

        context 'for a (defendant) uplift fee with one parent' do
          let(:fee) { create(:misc_fee, :miaph_fee, claim:, quantity: 1) }
          let(:uplift_fee) { create(:misc_fee, :miahu_fee, claim:, quantity: 2) }

          before do
            params[:fee_type_id] = uplift_fee.fee_type.id
            params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
          end

          it_returns 'a successful fee calculator response', unit: 'defendant', amount: 26.0
        end

        context 'for a (defendant) uplift with two possible parents (standard appearances)' do
          let(:fee) { create(:misc_fee, :misaf_fee, claim:, quantity: 1) }

          before do
            claim.case_type = nil
            allow(claim).to receive(:supplementary?).and_return true
          end

          context 'for a standard appearance fee' do
            it_returns 'a successful fee calculator response', unit: 'day', amount: 87.0
          end

          context 'for a standard appearance fee (defendant) uplift on supplementary claim' do
            let(:fee) { create(:misc_fee, :misaf_fee, claim:, quantity: 1) }
            let(:uplift_fee) { create(:misc_fee, :misau_fee, claim:, quantity: 2) }

            before do
              params[:fee_type_id] = uplift_fee.fee_type.id
              params[:fees].merge!('1': { fee_type_id: uplift_fee.fee_type.id, quantity: uplift_fee.quantity })
            end

            it_returns 'a successful fee calculator response', unit: 'defendant', amount: 17.4
          end
        end
      end

      context 'for erroneous requests' do
        context 'when invalid values supplied' do
          before { params.merge!(advocate_category: 'Not an advocate category') }

          it_returns 'a failed fee calculator response'
        end

        context 'when price calculation is excluded' do
          before do
            allow_any_instance_of(described_class).to receive(:exclusions).and_raise(Claims::FeeCalculator::Exceptions::RetrialReductionExclusion)
          end

          it_returns 'a failed fee calculator response', message: /insufficient_data/i
        end

        context 'when price not found' do
          before do
            allow_any_instance_of(described_class).to receive(:price).and_raise(Claims::FeeCalculator::Exceptions::PriceNotFound)
          end

          it_returns 'a failed fee calculator response', message: /price not found/i
        end

        context 'when too many prices' do
          before do
            allow_any_instance_of(described_class).to receive(:price).and_raise(Claims::FeeCalculator::Exceptions::TooManyPrices)
          end

          it_returns 'a failed fee calculator response', message: /too many prices/i
        end
      end
    end
  end

  context 'LGFS claims' do
    describe '#call' do
      subject(:response) { described_class.new(claim, params).call }

      let(:params) do
        {
          fee_type_id: fee.fee_type.id,
          fees: {
            '0': { fee_type_id: fee.fee_type.id, quantity: fee.quantity }
          }
        }
      end

      # IMPORTANT: use specific case type, offence (incl. explicit nil), fee types
      # and reporder date in order to reduce and afix VCR cassettes required (that have to match
      # on query values), prevent flickering specs (from random offence classes,
      # rep order dates) and to allow testing actual amounts "calculated".
      context 'LGFS scheme 9' do
        let(:claim) { create(:litigator_claim, case_type:, offence: nil, create_defendant_and_rep_order_for_scheme_9: true) }

        context 'for a case-type-specific fixed fee' do
          it_returns 'a successful fee calculator response', unit: 'day', amount: 349.47
        end

        context 'for a case-type-specific fixed fee with fixed amount (elected case not proceeded)' do
          let(:case_type) { create(:case_type, :elected_cases_not_proceeded) }
          let(:fee_type) { create(:fixed_fee_type, :fxenp) }
          let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

          it_returns 'a successful fee calculator response', unit: 'day', amount: 330.33
        end

        context 'for erroneous request' do
          before { params.merge!(fee_type_id: nil) }

          it_returns 'a failed fee calculator response'
        end
      end

      context 'LGFS scheme 10' do
        let(:claim) { create(:litigator_claim, case_type:, offence: nil, create_defendant_and_rep_order_for_scheme_10: true) }

        context 'for a case-type-specific fixed fee' do
          it_returns 'a successful fee calculator response', unit: 'day', amount: 401.89
        end

        context 'for a case-type-specific fixed fee with fixed amount (elected case not proceeded)' do
          let(:case_type) { create(:case_type, :elected_cases_not_proceeded) }
          let(:fee_type) { create(:fixed_fee_type, :fxenp) }
          let(:fee) { create(:fixed_fee, fee_type:, claim:, quantity: 1) }

          it_returns 'a failed fee calculator response'
        end

        context 'for erroneous request' do
          before { params.merge!(fee_type_id: nil) }

          it_returns 'a failed fee calculator response'
        end
      end
    end
  end
end
