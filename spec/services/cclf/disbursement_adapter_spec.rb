require 'rails_helper'

RSpec.describe CCLF::DisbursementAdapter, type: :adapter do
  let(:disbursement) { instance_double(Disbursement) }

  # For a given disbursement type the disbursement maps to a given CCLF bill type and sub type
  # however the bill scenario and "formula"* depend on the
  # case type and litigator claim type.
  # *nb: formula is used CCLF-side only and maps to whether to use quantity or amount???
  # NOTE: Costs judge prep, Cost judge application and travel costs have been softly deleted
  #
  DISBURSEMENT_BILL_TYPES = {
    ARP: %w[DISBURSEMENT ACCIDENT], # Accident reconstruction report
    ACC: %w[DISBURSEMENT ACCOUNTANTS], # Accounts
    SWX: %w[DISBURSEMENT COMPUTER_EXPERT], # Computer experts
    CMR: %w[DISBURSEMENT CONSULTANT_REP], # Consultant medical reports
    DNA: %w[DISBURSEMENT DNA_TESTING], # DNA testing
    ENG: %w[DISBURSEMENT ENGINEER], # Engineer
    ENQ: %w[DISBURSEMENT ENQUIRY_AGENTS], # Enquiry agents
    FMX: %w[DISBURSEMENT FACIAL_MAPPING], # wacial mapping expert
    FIN: ['DISBURSEMENT', 'FIN EXPERT'], # Financial expert
    DIG: %w[DISBURSEMENT FINGERPRINT], # Fingerprint expert
    EXP: %w[DISBURSEMENT FIRE_EXPLOSIVES], # Fire assessor/explosives expert
    FOR: %w[DISBURSEMENT FORENSICS], # Forensic scientists
    HWX: %w[DISBURSEMENT HANDWRITING], # Handwriting expert
    INT: %w[DISBURSEMENT INTERPRETERS], # Interpreter
    LIP: %w[DISBURSEMENT LIP_READERS], # Lip readers
    MED: ['DISBURSEMENT', 'MED EXPERT'], # Medical expert
    MCF: %w[DISBURSEMENT MEMO_CONV_FEE], # Memorandum of conviction fee
    MET: %w[DISBURSEMENT METEOROLOGIST], # Meteorologist
    XXX: %w[DISBURSEMENT OTHER], # Other
    ONX: %w[DISBURSEMENT OVERNIGHT_EXP], # Overnight expenses
    PTH: %w[DISBURSEMENT PATHOLOGISTS], # Pathologist
    COP: %w[DISBURSEMENT PHOTOCOPYING], # Photocopying
    PSY: %w[DISBURSEMENT PSYCHIATRIC_REP], # Psychiatric reports
    PLR: %w[DISBURSEMENT PSYCHO_REPORTS], # Psychological report
    ARC: %w[DISBURSEMENT SURVEYOR], # Surveyor/architect
    SCR: %w[DISBURSEMENT TRANSCRIPTS], # Transcripts
    TRA: %w[DISBURSEMENT TRANSLATOR], # Translator
    VET: %w[DISBURSEMENT VET_REPORT], # Vet report
    VOI: %w[DISBURSEMENT VOICE_RECOG] # Voice recognition
  }.freeze

  context 'bill mappings' do
    DISBURSEMENT_BILL_TYPES.each do |unique_code, bill_types|
      final_claim_bill_scenarios.each_key do |fee_type_code|
        context "when a disbursement of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
          subject(:instance) { described_class.new(disbursement) }

          let(:claim) { instance_double(Claim::LitigatorClaim, case_type:) }
          let(:case_type) { instance_double(CaseType, fee_type_code:) }
          let(:disbursement_type) { instance_double(DisbursementType, unique_code:) }

          before do
            allow(disbursement).to receive_messages(claim:, disbursement_type:)
          end

          describe '#bill_type' do
            subject { instance.bill_type }

            it "returns #{bill_types.first}" do
              is_expected.to eql bill_types.first
            end
          end

          describe '#bill_subtype' do
            subject { instance.bill_subtype }

            it "returns #{bill_types.second}" do
              is_expected.to eql bill_types.second
            end
          end
        end
      end
    end
  end
end
