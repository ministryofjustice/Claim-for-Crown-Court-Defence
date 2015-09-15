class ClaimSubModelValidator < BaseClaimValidator

  HAS_MANY_ASSOCIATION_NAMES = [ :defendants, :basic_fees, :misc_fees, :fixed_fees, :expenses, :messages, :redeterminations, :documents ]
  HAS_ONE_ASSOCIATION_NAMES  = [ :assessment, :certification ]

  def validate(record) 
    @result = true
    super
    validate_has_many_associations(record)
    validate_has_one_associations(record)
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

  def validate_has_one_associations(record)
    HAS_ONE_ASSOCIATION_NAMES.each do |association_name|
      associated_record = record.__send__(association_name)
      unless associated_record.nil?
        @result = false unless associated_record.valid?
      end
    end
  end

end


