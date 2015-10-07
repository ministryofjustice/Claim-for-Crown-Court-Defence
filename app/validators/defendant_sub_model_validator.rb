class DefendantSubModelValidator < BaseClaimValidator

  HAS_MANY_ASSOCIATION_NAMES = [ :representation_orders ]

  def validate(record)
    @result = true
    super
    validate_has_many_associations(record)
    record.errors.empty? && @result
  end

  private

  def validate_has_many_associations(record)
    HAS_MANY_ASSOCIATION_NAMES.each do |association_name|
      collection = record.__send__(association_name)
      collection.each do |associated_record|
        @result = false unless associated_record.valid?
      end
    end
  end

end