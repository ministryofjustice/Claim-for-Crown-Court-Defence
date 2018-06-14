class PreviousVersionOfClaim
  def initialize(claim)
    @claim = claim
  end

  def call
    reset if reset_needed?
    version
  end

  def reset_needed?
    version
  rescue ActiveRecord::SerializationTypeMismatch
    reset
  end

  def version
    @version ||= @claim.paper_trail.previous_version
  end

  private

  def reset
    version = PaperTrail::Version.where(item_type: 'Claim::BaseClaim', item_id: @claim.id).last
    new_object = version.object_deserialized.transform_values do |value|
      if value.present? && value.is_a?(Array)
        PaperTrail.serializer.dump value
      else
        value
      end
    end
    version.update_columns object: PaperTrail.serializer.dump(new_object)
  end
end
