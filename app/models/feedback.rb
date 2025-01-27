class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :referrer, :user_agent, :type,
                :event, :outcome, :case_number, :response_message

  validates :type, inclusion: { in: %w[bug_report] }
  validates :event, :outcome, presence: true, if: -> { is?(:bug_report) }

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end

    @reason.compact_blank! if @reason.present?
  end

  def is?(type)
    self.type == type.to_s
  end

  def save
    return unless valid? && !@sender.nil?

    resp = @sender.call(self)
    @response_message = resp[:response_message]
    resp[:success]
  end
end
