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

  validates :rating, inclusion: { in: '1'..'5' }

  def initialize(attributes = {})
    @email      = attributes[:email]
    @referrer   = attributes[:referrer]
    @user_agent = attributes[:user_agent]
    @comment    = attributes[:comment]
    @rating     = attributes[:rating]
  end

  def save
    return false unless valid?

    ZendeskFeedbackSender.send!(self)
    true
  end
end
