class DefendantDateValidator < BaseClaimValidator

  @@fields = [ :date_of_birth ]

  def self.fields
    @@fields
  end

  private

  def validate_date_of_birth
    validate_presence(:date_of_birth, "Please enter valid date of birth")
    validate_not_after(10.years.ago, :date_of_birth, "Date of birth must be at least 10 years ago")
    validate_not_before(120.years.ago, :date_of_birth, "Date of birth must not be more than 120 years ago")
  end

end
