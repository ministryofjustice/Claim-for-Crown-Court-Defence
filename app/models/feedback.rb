class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :text, :email, :referrer, :user_agent, :comment, :rating

  RATINGS = {
    5 => 'Very satisfied',
    4 => 'Satisfied',
    3 => 'Neither satisfied nor dissatisfied',
    2 => 'Dissatisfied',
    1 => 'Very dissatisfied'
  }
end
