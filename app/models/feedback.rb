class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  RATINGS = {
    5 => 'Very satisfied',
    4 => 'Satisfied',
    3 => 'Neither satisfied nor dissatisfied',
    2 => 'Dissatisfied',
    1 => 'Very dissatisfied'
  }.freeze

  FEEDBACK_TYPES = {
    feedback: [:rating, :comment, :email],
    bug_report: [:case_number, :event, :outcome, :email]
  }.freeze

  attr_accessor :email, :referrer, :user_agent, :type
  attr_accessor :event, :outcome, :case_number
  attr_accessor :comment, :rating

  validates :type, inclusion: { in: FEEDBACK_TYPES.keys.map(&:to_s) }
  validates :rating, inclusion: { in: RATINGS.keys.map(&:to_s) }, if: :feedback?
  validates :event, :outcome, presence: true, if: :bug_report?

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def feedback?
    is?(:feedback)
  end

  def bug_report?
    is?(:bug_report)
  end

  def is?(type)
    self.type == type.to_s
  end

  def save
    return false unless valid?
    ZendeskSender.send!(self)
    true
  end

  def subject
    "#{type.humanize} (#{Rails.host.env})"
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{self.send(t)}" }.join(' - ')
  end

  private

  def feedback_type_attributes
    FEEDBACK_TYPES[self.type.to_sym]
  end
end
