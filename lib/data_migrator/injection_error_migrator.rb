class String
  def to_error_messages
    hashed_error_messages.to_json
  end

  def hashed_error_messages
    arr = split(' {')

    arr_hash = arr.map do |error|
      err = error.starts_with?('{') ? error : error.prepend('{')
      err.to_hash!
    end

    { errors: arr_hash }
  end

  protected

  def to_hash!
    YAML.safe_load(gsub!('=>', ':'))
  end
end

module DataMigrator
  class InjectionErrorMigrator
    def migrate!
      puts '-- updating injection_attempts.error_messages from injection_attempts.error_message'
      injection_errors.each do |injection_error|
        begin
          injection_error.update(error_messages: injection_error.error_message.to_error_messages)
        rescue Psych::SyntaxError
          puts "Could not convert error_message:string for #{injection_error.id}"
        end
      end
    end

    def test
      injection_errors.each do |injection_error|
        puts "cast error_message #{injection_error.error_message}"
        puts "....to JSON error_messages: #{injection_error.error_message.to_error_messages}"
      end
    end

    private

    def injection_errors
      @injection_errors ||= InjectionAttempt.unscoped.where.not(error_message: nil).where(error_messages: nil)
    end
  end
end
