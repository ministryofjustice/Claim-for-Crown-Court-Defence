class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  FEEDBACK_TYPES = {
    feedback: %i[task rating comment reason other_reason],
    bug_report: %i[case_number event outcome email]
  }.freeze

  attr_accessor :email, :referrer, :user_agent, :type
  attr_accessor :event, :outcome, :case_number
  attr_accessor :task, :rating, :comment, :reason, :other_reason, :response_failed_message

  validates :type, inclusion: { in: FEEDBACK_TYPES.keys.map(&:to_s) }
  validates :event, :outcome, presence: true, if: :bug_report?

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end

    @reason.reject!(&:blank?) if @reason.present?
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
    return save_feedback if feedback?
    save_bug_report
  end

  def subject
    "#{type.humanize} (#{Rails.host.env})"
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{send(t)}" }.join(' - ')
  end

  private

  def save_feedback
    response = SurveyMonkeySender.call(self)
    @response_failed_message = "Unable to submit feedback [#{response[:error_code]}]" unless response[:success]
    response[:success]
  end

  def save_bug_report
    ZendeskSender.send!(self) unless is_feedback_with_empty_comment?
    true
  end

  def feedback_type_attributes
    FEEDBACK_TYPES[type.to_sym]
  end

  def is_feedback_with_empty_comment?
    feedback? && comment.to_s.empty?
  end
end
