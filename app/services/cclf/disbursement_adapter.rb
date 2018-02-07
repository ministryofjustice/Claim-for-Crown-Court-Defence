module CCLF
  class DisbursementAdapter < MappingBillAdapter
    # NOTE: TRV, CJA, CJP disabled/softly-deleted as handled as
    # expenses (TRV) and Misc Fees (CJA/CJP)
    #
    DISBURSEMENT_BILL_MAPPINGS = {
      ARP: zip(%w[DISBURSEMENT ACCIDENT]), # Accident reconstruction report
      ACC: zip(%w[DISBURSEMENT ACCOUNTANTS]), # Accounts
      SWX: zip(%w[DISBURSEMENT COMPUTER_EXPERT]), # Computer experts
      CMR: zip(%w[DISBURSEMENT CONSULTANT_REP]), # Consultant medical reports
      DNA: zip(%w[DISBURSEMENT DNA_TESTING]), # DNA testing
      ENG: zip(%w[DISBURSEMENT ENGINEER]), # Engineer
      ENQ: zip(%w[DISBURSEMENT ENQUIRY_AGENTS]), # Enquiry agents
      FMX: zip(%w[DISBURSEMENT FACIAL_MAPPING]), # wacial mapping expert
      FIN: zip(['DISBURSEMENT', 'FIN EXPERT']), # Financial expert
      DIG: zip(%w[DISBURSEMENT FINGERPRINT]), # Fingerprint expert
      EXP: zip(%w[DISBURSEMENT FIRE_EXPLOSIVES]), # Fire assessor/explosives expert
      FOR: zip(%w[DISBURSEMENT FORENSICS]), # Forensic scientists
      HWX: zip(%w[DISBURSEMENT HANDWRITING]), # Handwriting expert
      INT: zip(%w[DISBURSEMENT INTERPRETERS]), # Interpreter
      LIP: zip(%w[DISBURSEMENT LIP_READERS]), # Lip readers
      MED: zip(['DISBURSEMENT', 'MED EXPERT']), # Medical expert
      MCF: zip(%w[DISBURSEMENT MEMO_CONV_FEE]), # Memorandum of conviction fee
      MET: zip(%w[DISBURSEMENT METEOROLOGIST]), # Meteorologist
      XXX: zip(%w[DISBURSEMENT OTHER]), # Other
      ONX: zip(%w[DISBURSEMENT OVERNIGHT_EXP]), # Overnight expenses
      PTH: zip(%w[DISBURSEMENT PATHOLOGISTS]), # Pathologist
      COP: zip(%w[DISBURSEMENT PHOTOCOPYING]), # Photocopying
      PSY: zip(%w[DISBURSEMENT PSYCHIATRIC_REP]), # Psychiatric reports
      PLR: zip(%w[DISBURSEMENT PSYCHO_REPORTS]), # Psychological report
      ARC: zip(%w[DISBURSEMENT SURVEYOR]), # Surveyor/architect
      SCR: zip(%w[DISBURSEMENT TRANSCRIPTS]), # Transcripts
      TRA: zip(%w[DISBURSEMENT TRANSLATOR]), # Translator
      VET: zip(%w[DISBURSEMENT VET_REPORT]), # Vet report
      VOI: zip(%w[DISBURSEMENT VOICE_RECOG]) # Voice recognition
    }.freeze

    private

    def bill_mappings
      DISBURSEMENT_BILL_MAPPINGS
    end

    def bill_key
      object.disbursement_type.unique_code.to_sym
    end
  end
end
