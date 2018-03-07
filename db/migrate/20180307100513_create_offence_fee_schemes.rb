class CreateOffenceFeeSchemes < ActiveRecord::Migration
  def change
    create_table :offence_fee_schemes do |t|
      t.references :offence, index: true
      t.references :fee_scheme, index: true
    end

    agfs_scheme_nine = FeeScheme.find_by(name: 'AGFS', number: '9')
    lgfs_scheme_nine = FeeScheme.find_by(name: 'LGFS', number: '9')

    Offence.find_each do |offence|
      OffenceFeeScheme.create(offence: offence, fee_scheme: agfs_scheme_nine)
      OffenceFeeScheme.create(offence: offence, fee_scheme: lgfs_scheme_nine)
    end
  end
end
