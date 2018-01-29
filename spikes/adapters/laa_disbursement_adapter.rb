class LaaDisbursementAdapter
  TRANSLATION_TABLE = {
    'ARP' => 'ACCIDENT',
    'ACC' => 'ACCOUNTANTS',
    'SWX' => 'COMPUTER_EXPERT',
    'CMR' => 'CONSULTANT_REP',
    'CJA' => nil,
    'CJP' => nil,
    'DNA' => 'DNA_TESTING',
    'ENG' => 'ENGINEER',
    'ENQ' => 'ENQUIRY_AGENTS',
    'FMX' => 'FACIAL_MAPPING',
    'FIN' => 'FIN EXPERT',
    'DIG' => 'FINGERPRINT',
    'EXP' => 'FIRE_EXPLOSIVES',
    'FOR' => 'FORENSICS',
    'HWX' => 'HANDWRITING',
    'INT' => 'INTERPRETERS',
    'LIP' => 'LIP_READERS',
    'MED' => 'MED EXPERT',
    'MCF' => nil,
    'MET' => 'METEOROLOGIST',
    'XXX' => 'OTHER',
    'ONX' => 'OVERNIGHT_EXP',
    'PTH' => 'PATHOLOGISTS',
    'COP' => 'PHOTOCOPYING',
    'PSY' => 'PSYCHIATRIC_REP',
    'PLR' => 'PSYCHO_REPORTS',
    'ARC' => 'SURVEYOR',
    'SCR' => 'TRANSCRIPTS',
    'TRA' => 'TRANSLATOR',
    'TRV' => 'TRAVEL COSTS',
    'VET' => 'VET_REPORT',
    'VOI' => 'VOICE_RECOG'
  }.freeze

  LAA_BILL_TYPE = 'DISBURSEMENT'.freeze

  def self.laa_bill_type_and_sub_type(disbursement)
    sub_type = TRANSLATION_TABLE[disbursement.disbursement_type.unique_code]
    sub_type.nil? ? nil : [LAA_BILL_TYPE, sub_type]
  end
end
