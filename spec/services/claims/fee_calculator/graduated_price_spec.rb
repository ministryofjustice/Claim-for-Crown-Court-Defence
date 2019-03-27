# IMPORTANT: use specific case type, offence class, fee types and reporder
# date in order to reduce and afix VCR cassettes required (that have to match
# on query values), prevent flickering specs (from random offence classes,
# rep order dates) and to allow testing actual amounts "calculated".

RSpec.describe Claims::FeeCalculator::GraduatedPrice, :fee_calc_vcr do
  subject { described_class.new(claim, params) }

  context 'dummy' do
    let(:claim) { instance_double(::Claim::BaseClaim, agfs?: false, advocate_category: nil, earliest_representation_order_date: nil) }
    let(:params) { { fee_type_id: create(:graduated_fee_type, :grtrl).id } }

    it { is_expected.to respond_to(:call) }
    it { is_expected.to respond_to(:days) }
    it { is_expected.to respond_to(:ppe) }
  end

  describe '#call' do
    subject(:response) { described_class.new(claim, params).call }

    context 'LGFS' do
      let(:case_type) { create(:case_type, :trial) }
      let(:offence_class) { create(:offence_class, class_letter: 'J') }
      let(:offence) { create(:offence, offence_class: offence_class) }

      context 'final claim' do
        let(:claim) { create(
            :litigator_claim,
            create_defendant_and_rep_order_for_scheme_8: true,
            case_type: case_type,
            offence: offence
          )
        }

        let(:fee) { create(:graduated_fee, :trial_fee, claim: claim, date: scheme_date_for('lgfs'), quantity: 1) }
        let(:params) { { fee_type_id: fee.fee_type.id, days: 10, ppe: 1 } }

        it_returns 'a successful fee calculator response', amount: 5142.87

        context 'when 2 defendants' do
          before do
            claim.defendants << create(:defendant, scheme: 'lgfs')
          end

          context 'price is uplifted' do
            it_returns 'a successful fee calculator response', amount: 6171.44
          end
        end

        context 'when 2 defendants' do
          it_returns 'a successful fee calculator response',
                      number_of_defendants: 2,
                      scheme: 'lgfs',
                      amount: 6171.44
        end
      end

      context 'transfer claim' do
        let(:claim) {
          create(
            :transfer_claim,
            create_defendant_and_rep_order_for_scheme_8: true,
            offence: offence,
            litigator_type: 'new',
            elected_case: false,
            transfer_stage_id: 20, # Before trial transfer
            transfer_date: 3.months.ago,
            case_conclusion_id: 30 # Cracked
          )
        }
        let(:fee) { claim.transfer_fee }
        let(:params) { { fee_type_id: fee.fee_type.id } }

        it_returns 'a successful fee calculator response', amount: 904.58

        context 'when 2 defendants' do
          it_returns 'a successful fee calculator response',
                      number_of_defendants: 2,
                      scheme: 'lgfs',
                      amount: 1085.50
        end
      end

      context 'interim claims' do
        let(:claim) {
          create(
            :interim_claim,
            create_defendant_and_rep_order_for_scheme_8: true,
            offence: offence
          )
        }

        context 'effective PCMH' do
          let(:fee) { create(:interim_fee, :effective_pcmh, claim: claim, quantity: 100) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: nil, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 838.94
        end

        context 'trial start' do
          let(:fee) { create(:interim_fee, :trial_start, claim: claim) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: length, ppe: 80 } }

          TRIAL_LENGTH_BOUNDARIES = { 9 => 0.00, 10 => 1467.58, 11 => 1467.58 }

          TRIAL_LENGTH_BOUNDARIES.each_pair do |length, amount|
            context "with an estimated length of #{length}" do
              let(:length){ length }
              it_returns 'a successful fee calculator response', amount: amount
            end
          end

          context 'when 2 defendants' do
            let(:length) { 10 }
            it_returns 'a successful fee calculator response',
                        number_of_defendants: 2,
                        scheme: 'lgfs',
                        amount: 1761.10
          end
        end

        context 'retrial start' do
          let(:fee) { create(:interim_fee, :retrial_start, claim: claim) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: length, ppe: 80 } }

          RETRIAL_LENGTH_BOUNDARIES = { 9 => 0.00, 10 => 1467.58, 11 => 1467.58 }

          RETRIAL_LENGTH_BOUNDARIES.each_pair do |length, amount|
            context "with an estimated length of #{length}" do
              let(:length) { length }
              it_returns 'a successful fee calculator response', amount: amount
            end
          end
        end

        context 'retrial (new solicitor)' do
          let(:fee) { create(:interim_fee, :retrial_new_solicitor, claim: claim, quantity: 81) }
          let(:params) { { fee_type_id: fee.fee_type.id, days: nil, ppe: fee.quantity } }

          it_returns 'a successful fee calculator response', amount: 457.64
        end

        # TODO: this should return a failed response until
        # - fee calculator amended to have codes for warrant fee scenarios
        # - CCCD is able to apply the sub category of warrant fee scenario logic
        #
        context 'warrant' do
          before { claim.retrial_estimated_length = 3 }
          let(:fee) { create(:interim_fee, :warrant, claim: claim) }
          let(:params) { { fee_type_id: fee.fee_type.id } }

          context 'fee calculation excluded' do
            it_returns 'a failed fee calculator response', message: /insufficient_data/i
          end
        end
      end
    end

    context 'AGFS' do
      context 'basic (basic) fee' do
        let(:fee) { create(:basic_fee, :baf_fee, claim: claim) }

        context 'final claim' do
          let(:case_type) { create(:case_type, :trial) }

          context 'scheme 9' do
            let(:offence_class) { create(:offence_class, class_letter: 'A') }
            let(:offence) { create(:offence, offence_class: offence_class) }
            let(:claim) { create(:draft_claim, create_defendant_and_rep_order_for_scheme_9: true, case_type: case_type, offence: offence) }
            let(:params) { { fee_type_id: fee.fee_type.id, advocate_category: 'Junior alone', days: 1 } }

            context 'trial' do
              it_returns 'a successful fee calculator response', amount: 1632.00
            end

            context 'guilty plea' do
              let(:case_type) { create(:case_type, :guilty_plea) }
              it_returns 'a successful fee calculator response', amount: 979.00
            end

            context 'discontinuance' do
              let(:case_type) { create(:case_type, :discontinuance) }
              it_returns 'a successful fee calculator response', amount: 979.00
            end

            context 'retrial' do
              let(:case_type) { create(:case_type, :retrial) }

              context 'with retrial interval of negative calendar month' do
                before do
                  trial_end = 3.months.ago.to_date
                  retrial_start = trial_end - 6.months
                  allow(claim).to receive(:trial_concluded_at).and_return trial_end
                  allow(claim).to receive(:retrial_started_at).and_return retrial_start
                end

                context 'with retrial reduction requested' do
                  before { allow(claim).to receive(:retrial_reduction).and_return true }

                  # TODO: CCR Logic - TBC?? excluded for now
                  # context '0% reduction applies' do
                  #   it_returns 'a successful fee calculator response', amount: 1632.00
                  # end

                  context 'fee calculation excluded' do
                    it_returns 'a failed fee calculator response', message: /insufficient_data/i
                  end
                end

                context 'without retrial reduction' do
                  it_returns 'a successful fee calculator response', amount: 1632.00
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

                  context '30% reduction applies' do
                    it_returns 'a successful fee calculator response', amount: 1142.40
                  end
                end

                context 'without retrial reduction' do
                  it_returns 'a successful fee calculator response', amount: 1632.00
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

                  context '20% reduction applies' do
                    it_returns 'a successful fee calculator response', amount: 1305.60
                  end
                end

                context 'without retrial reduction' do
                  it_returns 'a successful fee calculator response', amount: 1632.00
                end
              end
            end

            context 'cracked trial' do
              let(:case_type) { create(:case_type, :cracked_trial) }

              context 'in first third' do
                before { allow(claim).to receive(:trial_cracked_at_third).and_return 'first_third' }
                it_returns 'a successful fee calculator response', amount: 979.00
              end

              context 'in second third' do
                before { allow(claim).to receive(:trial_cracked_at_third).and_return 'second_third' }
                it_returns 'a successful fee calculator response', amount: 1307.00
              end

              context 'in final third' do
                before { allow(claim).to receive(:trial_cracked_at_third).and_return 'final_third' }
                it_returns 'a successful fee calculator response', amount: 1307.00
              end
            end

            # TODO: Cracked before retrial - service needs to account for third_cracked and retrial_interval
            # - CCCD needs to expose "retrial reduction" option to user (as for retrials)
            # - CCCD needs may need to expose trial_concluded_at to determine retrial_interval
            # - negative retrial_intervals need consideration (as for retrials)
            #
            context 'cracked before retrial' do
              let(:case_type) { create(:case_type, :cracked_before_retrial) }

              context 'with retrial interval within one calendar month' do
                before do
                  trial_end = 3.months.ago.to_date
                  retrial_cracked = trial_end + 1.month
                  allow(claim).to receive(:trial_cracked_at_third).and_return 'final_third'
                  allow(claim).to receive(:trial_cracked_at).and_return retrial_cracked
                end

                context 'with retrial reduction requested' do
                  context '40% reduction applies', skip: 'needs retrial_interval and retrial_reduction' do
                    it_returns 'a successful fee calculator response', amount: 784.20
                  end

                  context 'fee calculation excluded' do
                    it_returns 'a failed fee calculator response', message: /insufficient_data/i
                  end
                end

                context 'without retrial reduction' do
                  context '0% reduction applies', skip: 'needs retrial_reduction' do
                    it_returns 'a successful fee calculator response', amount: 1307.00
                  end

                  context 'fee calculation excluded' do
                    it_returns 'a failed fee calculator response', message: /insufficient_data/i
                  end
                end
              end

              # TODO: no trial dates exist on cracked before retrial claims?
              context 'with retrial interval greater than one calendar month' do
                before do
                  trial_end = 3.months.ago.to_date
                  retrial_cracked = trial_end + 1.month + 1.day
                  allow(claim).to receive(:trial_cracked_at_third).and_return 'final_third'
                  allow(claim).to receive(:trial_cracked_at).and_return retrial_cracked
                end

                context 'with retrial reduction requested' do
                  context '25% reduction applies', skip: 'needs retrial_interval and retrial_reduction' do
                    it_returns 'a successful fee calculator response', amount: 980.25
                  end

                  context 'fee calculation excluded' do
                    it_returns 'a failed fee calculator response', message: /insufficient_data/i
                  end
                end

                context 'without retrial reduction' do
                  context '0% reduction applies', skip: 'needs retrial_reduction' do
                    it_returns 'a successful fee calculator response', amount: 1307.00
                  end

                  context 'fee calculation excluded' do
                    it_returns 'a failed fee calculator response', message: /insufficient_data/i
                  end
                end
              end
            end
          end

          context 'scheme 10' do
            let(:offence_band) { create(:offence_band, description: "1.1") }
            let(:offence) { create(:offence, :with_fee_scheme_ten, offence_band: offence_band) }
            let(:claim) { create(:draft_claim, create_defendant_and_rep_order_for_scheme_10: true, case_type: case_type, offence: offence) }
            let(:params) { { fee_type_id: fee.fee_type.id, advocate_category: 'Junior', days: 1 } }

            context 'trial' do
              it_returns 'a successful fee calculator response', amount: 8500.00
            end
          end

          context 'scheme 11' do
            let(:offence_band) { create(:offence_band, description: "1.1") }
            let(:offence) { create(:offence, :with_fee_scheme_eleven, offence_band: offence_band) }
            let(:claim) { create(:draft_claim, create_defendant_and_rep_order_for_scheme_11: true, case_type: case_type, offence: offence) }
            let(:params) { { fee_type_id: fee.fee_type.id, advocate_category: 'Junior', days: 1 } }

            context 'trial' do
              it_returns 'a successful fee calculator response', amount: 8585.00
            end
          end
        end
      end
    end

    context 'when api call fails' do
      let(:claim) { instance_double(::Claim::BaseClaim) }

      context 'because of incomplete parameters' do
        let(:params) { { fee_type_id: nil } }

        it_returns 'a failed fee calculator response', message: /insufficient_data/i
      end

      context 'because resource not found' do
        let(:claim) { instance_double(::Claim::BaseClaim, agfs?: false, advocate_category: 'QC', earliest_representation_order_date: Date.today, case_type: nil, retrial_reduction: false) }
        let(:params) { { fee_type_id: create(:graduated_fee_type, :grtrl).id } }

        before do
          stub_request(:get, %r{\Ahttps://laa-fee-calculator(.*).k8s.integration.dsd.io/api/v1/.*\z}).
            to_return(status: 404, body: {'error': '"detail": "Not found."'}.to_json, headers: {})
        end

        it_returns 'a failed fee calculator response', message: /not found/i
      end
    end
  end
end
