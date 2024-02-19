class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  FEEDBACK_TYPES = {
    feedback: %i[task rating comment reason other_reason],
    bug_report: %i[case_number event outcome email]
  }.freeze

  SENDING_SERVICES = [
    SurveyMonkeySender,
    ZendeskSender
  ].freeze

  attr_accessor :email, :referrer, :user_agent, :type,
                :event, :outcome, :case_number,
                :task, :rating, :comment, :reason, :other_reason, :response_message

  validates :type, inclusion: { in: FEEDBACK_TYPES.keys.map(&:to_s) }
  validates :event, :outcome, presence: true, if: :bug_report?

  def initialize(sender = nil, attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
    @sender = SENDING_SERVICES.include?(sender) ? sender : nil

    @reason.compact_blank! if @reason.present?
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
    return unless valid? || @sender.nil?

    resp = @sender.call(self)
    @response_message = resp[:response_message]
    resp[:success?]
  end

  def subject
    "#{type.humanize} (#{Rails.host.env})"
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{send(t)}" }.join("\n")
  end

  def reporter_email
    return if email.blank? || email == 'anonymous'

    email
  end

  private

  def feedback_type_attributes
    FEEDBACK_TYPES[type.to_sym]
  end
end
