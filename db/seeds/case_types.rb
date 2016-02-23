
def find_by_name_or_create(options)
  ct = CaseType.find_by_name(options[:name])
  if ct.nil?
    ct = CaseType.create!(options)
  end
end

find_by_name_or_create(name: 'Appeal against conviction',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Appeal against sentence',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                 
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Breach of Crown Court order',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  false,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Committal for Sentence',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Contempt',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Cracked Trial',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   true,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Cracked before retrial',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   true,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Discontinuance',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Elected cases not proceeded',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Guilty plea',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Retrial',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     true,
                            requires_retrial_dates:   true,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )
find_by_name_or_create(name: 'Trial',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     true,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      true,
                            requires_maat_reference:  true,
                            roles:                    ['agfs', 'lgfs'],
                            )

parent = find_by_name_or_create(name: 'Hearing subsequent to sentence',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            )

find_by_name_or_create(name: 'Transfer',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            )

find_by_name_or_create(name: 'Warrant claim',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            )

find_by_name_or_create(name: 'Vary/discharge an ASBO  s1c Crime and Disorder Act 1998',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            parent:                   parent
                            )

find_by_name_or_create(name: 'Alteration of Crown Court sentence s155 Powers of Criminal Courts (Sentencing Act 2000)',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            parent:                   parent
                            )
find_by_name_or_create(name: 'Assistance by defendant: review of sentence s74 Serious Organised Crime and Police Act 2005',
                            is_fixed_fee:             false,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            parent:                   parent
                            )
