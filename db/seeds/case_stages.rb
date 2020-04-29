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

ActiveRecord::Base.connection.reset_pk_sequence!(:case_stages)

SeedHelper.find_or_create_case_stage!(
  description: 'Pre PTPH',
  unique_code: 'PREPTPH',
  position: 10,
  case_type_id: CaseType.find_by(fee_type_code: 'GRDIS').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'After PTPH before trial',
  unique_code: 'AFTPTPH',
  position: 20,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRAK').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Trial started but not concluded',
  unique_code: 'TRLSBNC',
  position: 30,
  case_type_id: CaseType.find_by(fee_type_code: 'GRTRL').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Guilty plea not yet sentenced',
  unique_code: 'GLTNYS',
  position: 40,
  case_type_id: CaseType.find_by(fee_type_code: 'GRGLT').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Trial ended not yet sentenced',
  unique_code: 'TRLENYS',
  position: 50,
  case_type_id: CaseType.find_by(fee_type_code: 'GRTRL').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Retrial listed but not started',
  unique_code: 'RTRLBNS',
  position: 60,
  case_type_id: CaseType.find_by(fee_type_code: 'GRCBR').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Retrial started but not concluded',
  unique_code: 'RTRSBNC',
  position: 70,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRTR').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
  description: 'Retrial ended not yet sentenced',
  unique_code: 'RTRENYS',
  position: 80,
  case_type_id: CaseType.find_by(fee_type_code: 'GRRTR').id,
  roles: %w(agfs)
)

SeedHelper.find_or_create_case_stage!(
    description: 'PTPH not happened or been adjourned',
    unique_code: 'PTPHNYC',
    position: 90,
    case_type_id: CaseType.find_by(fee_type_code: 'GRTRL').id,
    roles: %w(lgfs)
)
