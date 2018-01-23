# WIP
# rubocop:disable Metrics/LineLength
#
# bill scenarios are a combination of the fee type and case type
# e.g ST1TS0T0 is a cracked trial - interim Payment - Effective PCMH
# each bill scenario has multiple bill types
# e.g ST1TS0T0 applies to DISBURSEMENT
#
# transfer brain data items
#
# [cclf_Scenario, cclf_scenario_description, cclf_trial_basis],[cccd_claim_type, cccd_transfer_claim_allocation_case_type, cccd_case_type, fee_type]
# [:ST1TS0T1, 'Discontinuances (Pre PCMH)', 'GUILTY PLEA'],['Claim::LitigatorClaim','Discontinuance', 'GRDIS'],
# [:ST1TS0T2, 'Guilty Plea', 'GUILTY PLEA'],['Claim::LitigatorClaim', 'Guilty Plea', 'GRGLT'],
# [:ST3TS1T2, 'Up to and including PCMH transfer (new) - Guilty Plea', 'GUILTY PLEA'],['Claim::TransferClaim', 'transfer_claim.transfer_fee_full_name e.g. Claim::TransferBrain.transfer_detail_summary(transfer.transfer_detail)','Guilty Plea', 'GRGLT'], #TRANSFER CLAIM
#
# rubocop:enable Metrics/LineLength
#
module CCR
  class BillScenarioAdapter
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
end
