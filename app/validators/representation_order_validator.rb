class RepresentationOrderValidator < BaseValidator

  def self.fields
    [
      :representation_order_date,
      :maat_reference
    ]
  end

  private

  # must not be blank
  # must not be too far in the past
  # must not be in the future
  # must not be earlier than the first rep order date
  def validate_representation_order_date
    validate_presence(:representation_order_date, "blank")
    validate_not_after(Date.today, :representation_order_date, "invalid")
    validate_not_before(Settings.earliest_permitted_date, :representation_order_date, "invalid")

    unless (@record.is_first_reporder_for_same_defendant?)
      first_reporder_date = @record.first_reporder_for_same_defendant.try(:representation_order_date)
      unless first_reporder_date.nil?
        validate_not_before(first_reporder_date, :representation_order_date, "invalid")
      end
    end
  end

  # mandatory where case type isn't breach of crown court order
  # must be exactly 7 - 10 numeric digits
  def validate_maat_reference
    case_type = @record.defendant.claim.case_type rescue nil
    if case_type && case_type.requires_maat_reference?
      validate_presence(:maat_reference, "invalid")
      validate_pattern(:maat_reference, /^[0-9]{7,10}$/, 'invalid')
    end
  end
end
