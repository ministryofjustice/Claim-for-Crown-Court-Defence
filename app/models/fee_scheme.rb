class FeeScheme
  def self.for_claim(claim)
    # TODO: Align this with Fee reform SPIKE
    return 'default' if claim.lgfs? || !FeatureFlag.active?(:agfs_fee_reform)
    date = claim.earliest_representation_order&.representation_order_date
    return unless date.present?
    date >= Date.parse(Settings.agfs_fee_reform_release_date.to_s) ? 'fee_reform' : 'default'
  end
end
