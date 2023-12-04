# #############################################################
# ErrorResponse Class: Retrieves validation error messages from
# translations file(s) and responds to erroneous API endpoint
# request with those error messages.
#
# error translations are divided into submodels:
# - Claim errors have no submodel.
# - Fee error translations are broken down into
#   the three different types plus a fallback type
#   ,in case the type is unknown.
# - Any other claim submodel should use its model
#   name in snake case.
#
# NOTE: for API we "spoof" the submodel count/number/instance
#       as 1
# #############################################################

module API
  class ErrorResponse
    attr_reader :body
    attr_reader :status

    attr_reader :error_messages

    VALID_MODEL_KLASSES = [
      Fee::GraduatedFee, Fee::InterimFee, Fee::TransferFee, Fee::BasicFee, Fee::MiscFee, Fee::FixedFee,
      Expense, Disbursement, Defendant, DateAttended, RepresentationOrder,
      Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::AdvocateSupplementaryClaim,
      Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim, Claim::AdvocateHardshipClaim,
      Claim::LitigatorHardshipClaim
    ].freeze

    def initialize(object)
      @error_messages = []

      if VALID_MODEL_KLASSES.include?(object.class)
        @model = object
        build_error_response
      else
        @status = object.try(:message) == 'Unauthorised' ? 401 : 400
        error_msg = object.try(:message).nil? ? "No message provided by object #{object.class.name}" : object.message
        @body = error_messages.push(error: error_msg)
      end
    end

    private

    def build_error_response
      raise 'unable to build error response as no errors were found' if @model.errors.empty?

      fetch_translated_error_messages
      @body = error_messages
      @status = 400
    end

    def fetch_translated_error_messages
      @model.errors.each do |error|
        key = translation_key(error.attribute)
        error = error.message
        message = translator.message(key, error)
        error_messages.push(error: message.api)
      end
    end

    def translation_key(attribute)
      :"#{model_index}#{attribute}"
    end

    def model_index
      "#{@model.class.name.demodulize.underscore}_1_" unless @model.is_a?(Claim::BaseClaim)
    end

    def translator
      @translator ||= ErrorMessage::Translator.new(translations)
    end

    def translations
      @translations ||= YAML.load_file(translations_file, aliases: true)
    end

    def translations_file
      ErrorMessage.default_translation_file
    end
  end
end
