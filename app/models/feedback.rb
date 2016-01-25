class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  RATINGS = {
    5 => 'Very satisfied',
    4 => 'Satisfied',
    3 => 'Neither satisfied nor dissatisfied',
    2 => 'Dissatisfied',
    1 => 'Very dissatisfied'
  }

  attr_accessor :email, :referrer, :user_agent, :comment, :rating

  validates :rating, inclusion: { in: RATINGS.keys.map(&:to_s) }

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def save
    valid? ? (ZendeskSender.send!(self); true) : false
  end

  def subject
    "Feedback (#{Rails.host.env})"
  end

  def description
    "#{self.rating} - #{self.comment} - #{self.email}"
  end
end
