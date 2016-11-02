require Rails.root.join('db','seed_helper')

[
  [1, 'ARP', 'Accident reconstruction report'],
  [2, 'ACC', 'Accounts'],
  [3, 'SWX', 'Computer experts'],
  [4, 'CMR', 'Consultant medical reports'],
  [5, 'CJA', 'Costs judge application fee'],
  [6, 'CJP', 'Costs judge preparation award'],
  [7, 'DNA', 'DNA testing'],
  [8, 'ENG', 'Engineer'],
  [9, 'ENQ', 'Enquiry agents'],
  [10, 'FMX', 'Facial mapping expert'],
  [11, 'FIN', 'Financial expert'],
  [12, 'DIG', 'Fingerprint expert'],
  [13, 'EXP', 'Fire assessor/explosives expert'],
  [14, 'FOR', 'Forensic scientists'],
  [15, 'HWX', 'Handwriting expert'],
  [16, 'INT', 'Interpreter'],
  [17, 'LIP', 'Lip readers'],
  [18, 'MED', 'Medical expert'],
  [19, 'MCF', 'Memorandum of conviction fee'],
  [20, 'MET', 'Meteorologist'],
  [21, 'XXX', 'Other'],
  [22, 'ONX', 'Overnight expenses'],
  [23, 'PTH', 'Pathologist'],
  [24, 'COP', 'Photocopying'],
  [25, 'PSY', 'Psychiatric reports'],
  [26, 'PLR', 'Psychological report'],
  [27, 'ARC', 'Surveyor/architect'],
  [28, 'SCR', 'Transcripts'],
  [29, 'TRA', 'Translator'],
  [30, 'TRV', 'Travel costs'],
  [31, 'VET', 'Vet report'],
  [32, 'VOI', 'Voice recognition'],
].each do |row|
  _record_id, unique_code, name = row
  SeedHelper.find_or_create_disbursement_type!(name, unique_code)
end
