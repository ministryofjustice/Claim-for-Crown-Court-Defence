# Chronological position, Stage Description, Graduated-fee/scenario/case-type
# 10, Pre PTPH, discontinuance
# 20, After PTPH before trial, cracked trial
# 30, Trial started but not concluded , trial
# 40, GP not yet sentenced , guilty plea
# 50, Trial ended not yet sentenced trial
# 60, Retrial listed but not started, cracked before retrial
# 70, Retrial started but not concluded, retrial
# 80, Retrial ended not yet sentenced retrial
#

require Rails.root.join('db','seed_helper')

SeedHelper.update_or_create_case_stage!(
  id: 11,
  description: 'Pre PTPH (evidence served)',
  unique_code: 'PREPTPHES',
  position: 5,
  case_type_id: CaseType.find_by(fee_type_code: 'GRGLT').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 1,
  description: 'Pre PTPH (no evidence served)',
  unique_code: 'PREPTPH',
  position: 10,
  case_type_id: CaseType.find_by(fee_type_code: 'GRDIS').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 2,
  description: 'After PTPH before trial',
  unique_code: 'AFTPTPH',
  position: 20,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRAK').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 3,
  description: 'Trial started but not concluded',
  unique_code: 'TRLSBNC',
  position: 30,
  case_type_id: CaseType.find_by(fee_type_code: 'GRTRL').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 4,
  description: 'Guilty plea not yet sentenced',
  unique_code: 'GLTNYS',
  position: 40,
  case_type_id: CaseType.find_by(fee_type_code: 'GRGLT').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 5,
  description: 'Trial ended not yet sentenced',
  unique_code: 'TRLENYS',
  position: 50,
  case_type_id: CaseType.find_by(fee_type_code: 'GRTRL').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 6,
  description: 'Retrial listed but not started',
  unique_code: 'RTRLBNS',
  position: 60,
  case_type_id: CaseType.find_by(fee_type_code: 'GRCBR').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 7,
  description: 'Retrial started but not concluded',
  unique_code: 'RTRSBNC',
  position: 70,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRTR').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 8,
  description: 'Retrial ended not yet sentenced',
  unique_code: 'RTRENYS',
  position: 80,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRTR').id,
  roles: %w(agfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 9,
  description: 'Pre PTPH (evidence served)',
  unique_code: 'NOPTPHWPPE',
  position: 90,
  case_type_id: CaseType.find_by(fee_type_code: 'GRGLT').id,
  roles: %w(lgfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 10,
  description: 'Pre PTPH (no evidence served)',
  unique_code: 'NOPTPHNOPPE',
  position: 100,
  case_type_id: CaseType.find_by(fee_type_code: 'GRDIS').id,
  roles: %w(lgfs)
)

SeedHelper.update_or_create_case_stage!(
  id: 12,
  description: 'Pre PTPH or PTPH adjourned',
  unique_code: 'PREPTPHADJ',
  position: 110,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRAK').id,
  roles: %w(lgfs)
)
