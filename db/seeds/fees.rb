basic = FeeType.find_or_create_by(name: 'Basic Fee & Enhancements (amount excluding VAT)')

Fee.find_or_create_by(fee_type: basic, description: 'Basic Fee', code: 'BAF')
Fee.find_or_create_by(fee_type: basic, description: 'Number of defendents uplift', code: 'NDR')
Fee.find_or_create_by(fee_type: basic, description: 'Number of cases uplift', code: 'NOC')

fixed = FeeType.find_or_create_by(name: 'Fixed Fees (amount excluding VAT)')

Fee.find_or_create_by(fee_type: fixed, description: 'Appeals to the Crown Court against Conviction', code: 'ACV')

misc = FeeType.find_or_create_by(name: 'Miscellaneous Fees (amount excluding VAT)')

Fee.find_or_create_by(fee_type: misc, description: 'Abuse of Process Hearings (Half Day)', code: 'APH')
Fee.find_or_create_by(fee_type: misc, description: 'Abuse of Process Hearings (Whole Day)', code: 'APW')
