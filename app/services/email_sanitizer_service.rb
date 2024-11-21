class EmailSanitizerService
  def initialize(email)
    @original_email = email
  end

  def call
    local, domain = @original_email.split('@')
    return "#{local[0]}*#{local[0]}@#{domain}" if local.length == 1
    return "#{local[0]}*#{local[1]}@#{domain}" if local.length == 2

    sanitized_local = local[0] + ('*' * (local.length - 2)) + local[-1]
    "#{sanitized_local}@#{domain}"
  end
end
