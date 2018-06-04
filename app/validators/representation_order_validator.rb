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

    validate_against_agfs_fee_reform_release_date
    validate_against_trial_dates
    validate_against_retrial_dates
    validate_against_case_concluded_date
    validate_against_first_rep_order_date
  end

  def validate_against_agfs_fee_reform_release_date
    return unless scheme_ten?
    validate_on_or_after(Settings.agfs_fee_reform_release_date, :representation_order_date, 'scheme_ten_offence')
  end

  def validate_against_trial_dates
    return unless claim&.requires_trial_dates?
    return if claim&.requires_retrial_dates?
    validate_on_or_before(claim.first_day_of_trial, :representation_order_date, 'not_on_or_before_first_day_of_trial')
  end

  def validate_against_retrial_dates
    return unless claim&.requires_retrial_dates?
    validate_on_or_before(claim.retrial_started_at, :representation_order_date, 'not_on_or_before_first_day_of_retrial')
  end

  def validate_against_case_concluded_date
    return unless claim&.requires_case_concluded_date?
    validate_on_or_before(claim.case_concluded_at, :representation_order_date, 'not_on_or_before_case_concluded_date')
  end

  def validate_against_first_rep_order_date
    return if @record.is_first_reporder_for_same_defendant?
    first_reporder_date = @record.first_reporder_for_same_defendant&.representation_order_date
    return if first_reporder_date.nil?
    validate_on_or_after(first_reporder_date, :representation_order_date, 'check')
  end

  # mandatory where case type isn't breach of crown court order
  # must be exactly 7 - 10 numeric digits
  def validate_maat_reference
    case_type = claim.try(:case_type)
    return unless case_type&.requires_maat_reference?
    validate_presence(:maat_reference, 'invalid')
    validate_pattern(:maat_reference, /^[0-9]{7,10}$/, 'invalid')
  end

  # helper methods
  #
  def claim
    @record.defendant.claim
  end

  def scheme_ten?
    claim&.offence&.scheme_ten?
  end

  def earliest_permitted
    if claim&.lgfs? && claim&.interim?
      { date: Settings.interim_earliest_permitted_repo_date, error: 'not_before_interim_earliest_permitted_date' }
    else
      { date: Settings.earliest_permitted_date, error: 'not_before_earliest_permitted_date' }
    end
  end
end
