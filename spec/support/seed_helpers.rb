module SeedHelpers
  def seed_fee_schemes
    FeeScheme.find_by(name: 'LGFS', version: 9) || create(:fee_scheme, :lgfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 9) || create(:fee_scheme, :agfs_nine)
    FeeScheme.find_by(name: 'AGFS', version: 10) || create(:fee_scheme, :agfs_ten)
  end
end
