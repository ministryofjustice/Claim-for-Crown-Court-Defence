class BugReport
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :referrer, :user_agent, :event, :outcome

  validates :event, presence: true
  validates :outcome, presence: true

  def initialize(attributes = {})
    @email      = attributes[:email]
    @referrer   = attributes[:referrer]
    @user_agent = attributes[:user_agent]
    @event    = attributes[:event]
    @outcome     = attributes[:outcome]
  end

  def save
    return false unless valid?

    ZendeskSender.send!(self)
    true
  end

  def subject
    "Bug report (#{Rails.host.env})"
  end

  def description
    "#{self.event} - #{self.outcome} - #{self.email}"
  end

end
