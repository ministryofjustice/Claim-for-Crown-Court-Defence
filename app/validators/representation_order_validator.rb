class RepresentationOrderValidator < BaseValidator
  def self.fields
    %i[
      representation_order_date
      maat_reference
    ]
  end

  private

  # must not be blank
  # must not be too far in the past
  # must not be in the future
  # must not be earlier than the first rep order date
  # must not be earlier than the earliest permitted date
  def validate_representation_order_date
    validate_presence(:representation_order_date, 'blank')
    validate_on_or_before(Date.today, :representation_order_date, 'in_future')
    validate_on_or_after(earliest_permitted[:date], :representation_order_date, earliest_permitted[:error])

    return if @record.is_first_reporder_for_same_defendant?
    first_reporder_date = @record.first_reporder_for_same_defendant.try(:representation_order_date)
    return if first_reporder_date.nil?
    validate_on_or_after(first_reporder_date, :representation_order_date, 'check')
  end

  # mandatory where case type isn't breach of crown court order
  # must be exactly 7 - 10 numeric digits
  def validate_maat_reference
    case_type = claim.try(:case_type)
    validate_presence(:maat_reference, 'invalid') if case_type&.requires_maat_reference?
    validate_pattern(:maat_reference, /^[0-9]{7,10}$/, 'invalid') if @record.maat_reference.present?
  end

  # helper methods
  #
  def claim
    @record.defendant.claim
  end

  def earliest_permitted
    return { date: Settings.interim_earliest_permitted_repo_date, error: 'not_before_interim_earliest_permitted_date' } if claim.try(:interim?)
    { date: Settings.earliest_permitted_date, error: 'not_before_earliest_permitted_date' }
  end
end
