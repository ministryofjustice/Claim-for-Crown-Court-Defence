

def create_or_update_by_name  (options)
  ct = CaseType.find_by_name(options[:name])
  if ct.nil?
    ct = CaseType.create!(options)
  else
    ct.update!(options)
  end
  ct
end

create_or_update_by_name(name:                       'Appeal against conviction',
                            is_fixed_fee:            true,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     false,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'FXACV',
                            uuid: 'a05f6ee1-c9fb-4069-9789-1f68aea85fb8'
                            )
create_or_update_by_name(name:                      'Appeal against sentence',
                            is_fixed_fee:           true,
                            requires_cracked_dates: false,
                            requires_trial_dates:   false,
                            requires_retrial_dates: false,
                            allow_pcmh_fee_type:    false,
                            roles:                  %w(agfs lgfs),
                            fee_type_code:          'FXASE',
                            uuid: '2c4bc4a3-9246-4841-9813-a1e03b8d3a05'
                            )
create_or_update_by_name(name:                       'Breach of Crown Court order',
                            is_fixed_fee:            true,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     false,
                            requires_maat_reference: false,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'FXCBR',
                            uuid: '4e996aed-2dc9-424c-9862-b52b02fe48b3'
                            )
create_or_update_by_name(name:                       'Committal for Sentence',
                            is_fixed_fee:            true,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     false,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'FXCSE',
                            uuid: '7c27f365-9cd3-4993-b78d-2065ecb97fd9'
                            )
create_or_update_by_name(name:                       'Contempt',
                            is_fixed_fee:            true,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     false,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'FXCON',
                            uuid: 'b6d8bc8e-7238-458e-a645-c0e382a5afd1'
                            )
create_or_update_by_name(name:                       'Cracked Trial',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  true,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'GRRAK',
                            uuid: '60e835cf-911f-49ef-9376-8b2a55494aa6'
                            )
create_or_update_by_name(name:                       'Cracked before retrial',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  true,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'GRCBR',
                            uuid: '5db5134a-afac-4f32-bc88-e9a6a54b4df9'
                            )
create_or_update_by_name(name:                       'Discontinuance',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'GRDIS',
                            uuid: '5d646fd1-b50b-4aba-9435-de5b9377bd8a'
                            )
create_or_update_by_name(name:                       'Elected cases not proceeded',
                            is_fixed_fee:            true,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     false,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'FXENP',
                            uuid: '03cb932c-d700-415b-a328-15839d88dc36'
                            )
create_or_update_by_name(name:                       'Guilty plea',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    false,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs),
                            fee_type_code:           'GRGLT',
                            uuid: 'b342a476-887d-46b3-b2dc-32da2dd138ec'
                            )
create_or_update_by_name(name:                       'Retrial',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    true,
                            requires_retrial_dates:  true,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs interim),
                            fee_type_code:           'GRRTR',
                            uuid: 'c6197718-08c5-4943-a2e1-2c5bf71bcfa8'
                            )
create_or_update_by_name(name:                       'Trial',
                            is_fixed_fee:            false,
                            requires_cracked_dates:  false,
                            requires_trial_dates:    true,
                            requires_retrial_dates:  false,
                            allow_pcmh_fee_type:     true,
                            requires_maat_reference: true,
                            roles:                   %w(agfs lgfs interim),
                            fee_type_code:           'GRTRL',
                            uuid: 'f96b265a-f972-4872-a598-e78de4fcab83'
                            )

create_or_update_by_name(name: 'Hearing subsequent to sentence',
                            is_fixed_fee:             true,
                            requires_cracked_dates:   false,
                            requires_trial_dates:     false,
                            requires_retrial_dates:   false,
                            allow_pcmh_fee_type:      false,
                            requires_maat_reference:  true,
                            roles:                    ['lgfs'],
                            fee_type_code:            'FXH2S',
                            uuid: '5e1d62c4-b119-4b48-9811-3c92c93dee9e'
                            )

# create_or_update_by_name(name: 'Transfer',
#                             is_fixed_fee:             false,
#                             requires_cracked_dates:   false,
#                             requires_trial_dates:     false,
#                             requires_retrial_dates:   false,
#                             allow_pcmh_fee_type:      false,
#                             requires_maat_reference:  true,
#                             roles:                    ['lgfs'],
#                             )
#
# create_or_update_by_name(name: 'Warrant claim',
#                             is_fixed_fee:             false,
#                             requires_cracked_dates:   false,
#                             requires_trial_dates:     false,
#                             requires_retrial_dates:   false,
#                             allow_pcmh_fee_type:      false,
#                             requires_maat_reference:  true,
#                             roles:                    ['lgfs'],
#                             )
