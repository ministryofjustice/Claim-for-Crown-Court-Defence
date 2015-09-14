CaseType.find_or_create_by!(name: 'Appeal against conviction',    is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Appeal against sentence',      is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Breach of Crown Court order',  is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Commital for Sentence',        is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Contempt',                     is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Cracked Trial',                is_fixed_fee: false,  requires_cracked_dates: true,  requires_trial_dates: false, allow_pcmh_fee_type: true)
CaseType.find_or_create_by!(name: 'Cracked before retrial',       is_fixed_fee: false,  requires_cracked_dates: true,  requires_trial_dates: false, allow_pcmh_fee_type: true)
CaseType.find_or_create_by!(name: 'Discontinuance',               is_fixed_fee: false,  requires_cracked_dates: false, requires_trial_dates: true,  allow_pcmh_fee_type: true)
CaseType.find_or_create_by!(name: 'Elected cases not proceeded',  is_fixed_fee: true,   requires_cracked_dates: false, requires_trial_dates: false, allow_pcmh_fee_type: false)
CaseType.find_or_create_by!(name: 'Guilty plea',                  is_fixed_fee: false,  requires_cracked_dates: false, requires_trial_dates: true,  allow_pcmh_fee_type: true)
CaseType.find_or_create_by!(name: 'Retrial',                      is_fixed_fee: false,  requires_cracked_dates: false, requires_trial_dates: true,  allow_pcmh_fee_type: true)
CaseType.find_or_create_by!(name: 'Trial',                        is_fixed_fee: false,  requires_cracked_dates: false, requires_trial_dates: true,  allow_pcmh_fee_type: true)



