class FeeScheme < ActiveRecord::Base
  SCHEME9 = 9
  SCHEME10 = 10
  validates :start_date, :version, :name, presence: true

  has_many :offence_fee_schemes
  has_many :offences, through: :offence_fee_schemes

  scope :agfs, -> { where(name: 'AGFS') }
  scope :lgfs, -> { where(name: 'LGFS') }
  scope :current, lambda {
    where('(:now BETWEEN start_date AND end_date) OR (start_date < :now AND end_date IS NULL)', now: Time.zone.now)
  }
  scope :for, lambda { |check_date|
    where('(:date BETWEEN start_date AND end_date) OR (start_date < :date AND end_date IS NULL)', date: check_date)
  }

  def self.current_agfs
    agfs.current.order(end_date: :desc).first
  end

  def self.current_lgfs
    lgfs.current.order(end_date: :desc).first
  end

  def self.for_claim(claim)
    # TODO: Align this with Fee reform SPIKE
    return 'default' if claim.lgfs? || !FeatureFlag.active?(:agfs_fee_reform)
    date = claim.earliest_representation_order&.representation_order_date
    return unless date.present?
    date >= Date.parse(Settings.agfs_fee_reform_release_date.to_s) ? 'fee_reform' : 'default'
  end
end
