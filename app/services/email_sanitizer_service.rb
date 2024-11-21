class EmailSanitizerService
  def initialize(email)
    @original_email = email
  end

  def call
    local, domain = @original_email.split('@')
    return 'Invalid email, cannot be redacted' if local.nil? || domain.nil?

    "#{redact(local)}@#{redact_domain(domain)}"
  end

  private

  def redact(input)
    return "#{input[0]}*#{input[0]}" if input.length == 1
    return "#{input[0]}*#{input[1]}" if input.length == 2

    input[0] + ('*' * (input.length - 2)) + input[-1]
  end

  def redact_domain(domain)
    parts = domain.split('.')
    parts[0..-2] = parts[0..-2].map { |part| redact(part) } if parts.length > 1
    parts.join('.')
  end
end
