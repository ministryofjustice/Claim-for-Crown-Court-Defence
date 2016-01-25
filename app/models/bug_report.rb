class BugReport
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :referrer, :user_agent, :event, :outcome

  validates :event, :outcome, presence: true

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def save
    valid? ? (ZendeskSender.send!(self); true) : false
  end

  def subject
    "Bug report (#{Rails.host.env})"
  end

  def description
    "#{self.event} - #{self.outcome} - #{self.email}"
  end
end
