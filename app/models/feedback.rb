class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  TASKS = {
    3 => 'Yes',
    2 => 'No',
    1 => 'Partially'
  }.freeze

  RATINGS = {
    5 => 'Very satisfied',
    4 => 'Satisfied',
    3 => 'Neither satisfied nor dissatisfied',
    2 => 'Dissatisfied',
    1 => 'Very dissatisfied'
  }.freeze

  REASONS = {
    3 => 'Submit a LGFS Claims',
    2 => 'Submit an AGFS Claims',
    1 => 'Other (please specify)'
  }.freeze

  FEEDBACK_TYPES = {
    feedback: %i[task rating comment reason other_reason],
    bug_report: %i[case_number event outcome email]
  }.freeze

  attr_accessor :email, :referrer, :user_agent, :type
  attr_accessor :event, :outcome, :case_number
  attr_accessor :task, :rating, :comment, :reason, :other_reason

  validates :type, inclusion: { in: FEEDBACK_TYPES.keys.map(&:to_s) }
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
    ZendeskSender.send!(self) unless is_feedback_with_empty_comment?
    true
  end

  def subject
    "#{type.humanize} (#{Rails.host.env})"
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{send(t)}" }.join(' - ')
  end

  private

  def feedback_type_attributes
    FEEDBACK_TYPES[type.to_sym]
  end

  def is_feedback_with_empty_comment?
    feedback? && comment.to_s.empty?
  end
end
