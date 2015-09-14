class DefendantValidator < BaseClaimValidator

  private

  def self.fields
    [ :date_of_birth, :representation_orders, :first_name, :last_name ]
  end

  def self.mandatory_fields
    [ :claim ]
  end

  

  def validate_date_of_birth
    validate_presence(:date_of_birth, error_message_for(:defendant, :date_of_birth, :blank))
    validate_not_after(10.years.ago, :date_of_birth, "Date of birth must be at least 10 years ago")
    validate_not_before(120.years.ago, :date_of_birth, "Date of birth must not be more than 120 years ago")
  end


  def validate_representation_orders
    unless @record.claim && @record.claim.api_draft?
      if @record.representation_orders.none?
        add_error(:representation_orders, I18n.t("activerecord.errors.models.defendant.attributes.representation_orders.blank") )
      end
    end
  end


  def validate_claim
    validate_presence(:claim, error_message_for(:defendant, :claim, :blank))
  end

  def validate_first_name
    validate_presence(:first_name, error_message_for(:defendant, :first_name, :blank))
  end

  def validate_last_name
    validate_presence(:last_name, error_message_for(:defendant, :last_name, :blank))
  end


  

end
