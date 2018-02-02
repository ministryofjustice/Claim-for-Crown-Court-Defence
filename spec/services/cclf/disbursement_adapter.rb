require 'rails_helper'
require 'spec_helper'

RSpec.describe CCLF::Fee::DisbursementAdapter, type: :adapter do

  # For a given disbursement type the disbursement maps to a given CCLF bill type and sub type
  # however the bill scenario and "formula"* depend on the
  # case type and litigator claim type.
  # *nb: formula is used CCLF-side only and maps to whether to use quantity or amount???
  #
  DISBURSEMENT_BILL_TYPES = {
    ARP: ['DISBURSEMENT', 'ACCIDENT'], # Accident reconstruction report
    ACC: ['DISBURSEMENT', 'ACCOUNTANTS'], # Accounts
    SWX: ['DISBURSEMENT', 'COMPUTER_EXPERT'], # Computer experts
    CMR: ['DISBURSEMENT', 'CONSULTANT_REP'], # Consultant medical reports
    CJA: ['DISBURSEMENT', 'TBC'], # TODO: "Costs judge application fee" - this is a miscelleneous fee too
    CJP: ['DISBURSEMENT', 'TBC'], # TODO: "Costs judge preparation award" - this is a miscelleneous fee too
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
    TRV: ['DISBURSEMENT', 'TRAVEL COSTS'], # Travel costs
    VET: ['DISBURSEMENT', 'VET_REPORT'], # Vet report
    VOI: ['DISBURSEMENT', 'VOICE_RECOG'], # Voice recognition
  }.freeze

  DISBURSEMENT_BILL_SCENARIOS = {
    FXACV: 'ST1TS0T5', # Appeal against conviction
    FXASE: 'ST1TS0T6', # Appeal against sentence
    FXCBR: 'ST3TS3TB', # Breach of Crown Court order
    FXCSE: 'ST1TS0T7', # Committal for Sentence
    FXCON: 'ST1TS0T8', # Contempt
    FXENP: 'ST4TS0T1', # Elected cases not proceeded
    FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
    GRDIS: 'ST1TS0T1', # Discontinuance
    GRGLT: 'ST1TS0T2', # Guilty plea
    GRTRL: 'ST1TS0T4', # Trial
    GRRTR: 'ST1TS0TA', # Retrial
    GRRAK: 'ST1TS0T3', # Cracked trial
    GRCBR: 'ST1TS0T9', # Cracked before retrial
  }.freeze

context 'bill mappings' do
    DISBURSEMENT_BILL_TYPES.each do |unique_code, bill_types|
      DISBURSEMENT_BILL_SCENARIOS.each do |fee_type_code, scenario|
        context "when a misc fee of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
          subject(:instance) { described_class.new(fee) }
          let(:claim) { instance_double(::Claim::LitigatorClaim, case_type: case_type) }
          let(:case_type) { instance_double(::CaseType, fee_type_code: fee_type_code) }
          let(:fee_type) { instance_double(::Fee::MiscFeeType, unique_code: unique_code) }

          before do
            allow(fee).to receive(:claim).and_return claim
            allow(fee).to receive(:fee_type).and_return fee_type
          end

          describe '#bill_type' do
            it "returns #{bill_types.first}" do
              expect(instance.bill_type).to eql bill_types.first
            end
          end

          describe '#bill_subtype' do
            it "returns #{bill_types.second}" do
              expect(instance.bill_subtype).to eql bill_types.second
            end
          end

          describe '#bill_scenario' do
            it "returns #{scenario}" do
              expect(instance.bill_scenario).to eql scenario
            end
          end
        end
      end
    end
  end
end
