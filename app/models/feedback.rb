class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  FEEDBACK_TYPES = {
    feedback: %i[task rating comment reason other_reason],
    bug_report: %i[case_number event outcome email]
  }.freeze

  attr_accessor :email, :referrer, :user_agent, :type
  attr_accessor :event, :outcome, :case_number
  attr_accessor :task, :rating, :comment, :reason, :other_reason, :response_message

  validates :type, inclusion: { in: FEEDBACK_TYPES.keys.map(&:to_s) }
  validates :event, :outcome, presence: true, if: :bug_report?

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end

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
    return unless valid?
    return save_feedback if feedback?
    save_bug_report
  end

  def subject
    "#{type.humanize} (#{Rails.host.env})"
  end

  def description
    feedback_type_attributes.map { |t| "#{t}: #{send(t)}" }.join("\n")
  end

  private

  def save_feedback
    if Settings.zendesk_feedback_enabled?
      send_to_zendesk('Feedback')
    else
      send_to_survey_monkey
    end
  end

  def save_bug_report
    send_to_zendesk('Fault')
  end

  def send_to_survey_monkey
    response = SurveyMonkeySender.call(self)
    @response_message = if response[:success]
                          'Feedback submitted'
                        else
                          "Unable to submit feedback [#{response[:error_code]}]"
                        end
    response[:success]
  end

  def send_to_zendesk(feedback_type)
    ZendeskSender.send!(self)
    @response_message = "#{feedback_type} submitted"
  rescue ZendeskAPI::Error::ClientError => e
    @response_message = "Unable to submit #{feedback_type.downcase}"
    LogStuff.error(class: self.class.name, action: 'save', error_class: e.class.name, error: e.to_s) do
      "#{feedback_type} submisson failed!"
    end
    false
  end

  def feedback_type_attributes
    FEEDBACK_TYPES[type.to_sym]
  end
end
