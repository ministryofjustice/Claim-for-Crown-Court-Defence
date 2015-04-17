basic = FeeCategory.find_or_create_by(name: 'Basic Fee & Enhancements (amount excluding VAT)')

Fee.find_or_create_by(fee_category: basic, description: 'Basic Fee', code: 'BAF')
Fee.find_or_create_by(fee_category: basic, description: 'Number of defendents uplift', code: 'NDR')
Fee.find_or_create_by(fee_category: basic, description: 'Number of cases uplift', code: 'NOC')

fixed = FeeCategory.find_or_create_by(name: 'Fixed Fees (amount excluding VAT)')

Fee.find_or_create_by(fee_category fixed, description: 'Appeals to the Crown Court against Conviction', code: 'ACV')

misc = FeeCategory.find_or_create_by(name: 'Miscellaneous Fees (amount excluding VAT)')

Fee.find_or_create_by(fee_category: misc, description: 'Abuse of Process Hearings (Half Day)', code: 'APH')
Fee.find_or_create_by(fee_category: misc, description: 'Abuse of Process Hearings (Whole Day)', code: 'APW')
