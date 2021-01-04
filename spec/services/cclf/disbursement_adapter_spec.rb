require 'rails_helper'

RSpec.describe CCLF::DisbursementAdapter, type: :adapter do
  let(:disbursement) { instance_double(::Disbursement) }

  # For a given disbursement type the disbursement maps to a given CCLF bill type and sub type
  # however the bill scenario and "formula"* depend on the
  # case type and litigator claim type.
  # *nb: formula is used CCLF-side only and maps to whether to use quantity or amount???
  # NOTE: Costs judge prep, Cost judge application and travel costs have been softly deleted
  #
  DISBURSEMENT_BILL_TYPES = {
    ARP: ['DISBURSEMENT', 'ACCIDENT'], # Accident reconstruction report
    ACC: ['DISBURSEMENT', 'ACCOUNTANTS'], # Accounts
    SWX: ['DISBURSEMENT', 'COMPUTER_EXPERT'], # Computer experts
    CMR: ['DISBURSEMENT', 'CONSULTANT_REP'], # Consultant medical reports
    DNA: ['DISBURSEMENT', 'DNA_TESTING'], # DNA testing
    ENG: ['DISBURSEMENT', 'ENGINEER'], # Engineer
    ENQ: ['DISBURSEMENT', 'ENQUIRY_AGENTS'], # Enquiry agents
    FMX: ['DISBURSEMENT', 'FACIAL_MAPPING'], # wacial mapping expert
    FIN: ['DISBURSEMENT', 'FIN EXPERT'], # Financial expert
    DIG: ['DISBURSEMENT', 'FINGERPRINT'], # Fingerprint expert
    EXP: ['DISBURSEMENT', 'FIRE_EXPLOSIVES'], # Fire assessor/explosives expert
    FOR: ['DISBURSEMENT', 'FORENSICS'], # Forensic scientists
    HWX: ['DISBURSEMENT', 'HANDWRITING'], # Handwriting expert
    INT: ['DISBURSEMENT', 'INTERPRETERS'], # Interpreter
    LIP: ['DISBURSEMENT', 'LIP_READERS'], # Lip readers
    MED: ['DISBURSEMENT', 'MED EXPERT'], # Medical expert
    MCF: ['DISBURSEMENT', 'MEMO_CONV_FEE'], # Memorandum of conviction fee
    MET: ['DISBURSEMENT', 'METEOROLOGIST'], # Meteorologist
    XXX: ['DISBURSEMENT', 'OTHER'], # Other
    ONX: ['DISBURSEMENT', 'OVERNIGHT_EXP'], # Overnight expenses
    PTH: ['DISBURSEMENT', 'PATHOLOGISTS'], # Pathologist
    COP: ['DISBURSEMENT', 'PHOTOCOPYING'], # Photocopying
    PSY: ['DISBURSEMENT', 'PSYCHIATRIC_REP'], # Psychiatric reports
    PLR: ['DISBURSEMENT', 'PSYCHO_REPORTS'], # Psychological report
    ARC: ['DISBURSEMENT', 'SURVEYOR'], # Surveyor/architect
    SCR: ['DISBURSEMENT', 'TRANSCRIPTS'], # Transcripts
    TRA: ['DISBURSEMENT', 'TRANSLATOR'], # Translator
    VET: ['DISBURSEMENT', 'VET_REPORT'], # Vet report
    VOI: ['DISBURSEMENT', 'VOICE_RECOG'] # Voice recognition
  }.freeze

  context 'bill mappings' do
    DISBURSEMENT_BILL_TYPES.each do |unique_code, bill_types|
      final_claim_bill_scenarios.each do |fee_type_code, scenario|
        context "when a disbursement of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
          subject(:instance) { described_class.new(disbursement) }
          let(:claim) { instance_double(::Claim::LitigatorClaim, case_type: case_type) }
          let(:case_type) { instance_double(::CaseType, fee_type_code: fee_type_code) }
          let(:disbursement_type) { instance_double(::DisbursementType, unique_code: unique_code) }

          before do
            allow(disbursement).to receive(:claim).and_return claim
            allow(disbursement).to receive(:disbursement_type).and_return disbursement_type
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
