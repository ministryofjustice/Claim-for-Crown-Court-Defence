class RepresentationOrderDateValidator < BaseClaimValidator

  @@fields = [ :representation_order_date ]

  def self.fields
    @@fields
  end

  private

  # must not be blank
  # must not be too far in the past
  # must not be in the future
  # must not be earlier than the first rep order date
  def validate_representation_order_date
    validate_presence(:representation_order_date, "Please enter a valid representation order date")
    validate_not_after(Date.today, :representation_order_date, "Representation order date must not be in the future")
    validate_not_before(Settings.earliest_permitted_date, :representation_order_date, "The representation order date may not be more than #{Settings.earliest_permitted_date_in_words}")

    unless (@record.is_first_reporder_for_same_defendant?)
      first_reporder_date = @record.first_reporder_for_same_defendant.try(:representation_order_date)
      unless first_reporder_date.nil?
        validate_not_before(first_reporder_date, :representation_order_date, "The date of the second and subsequent representation orders must not be before the date of the first represenation order")
      end
    end

  end


end

