module CheckSummable
  def add_checksum(asset)
    io = Paperclip.io_adapters.for(send(asset))
    send("as_#{asset}_checksum=", calculate_checksum(io))
  rescue Errno::ENOENT => e
    checksum_log("File not found: #{send(asset).path}", e)
  rescue Errno::ENAMETOOLONG => e
    checksum_log("Filename too long: #{send(asset).path}", e)
  rescue StandardError => e
    checksum_log("Unexpected error: #{send(asset).path}", e)
  end

  def calculate_checksum(io)
    return if io.nil?

    checksum = Digest::MD5.new
    while (chunk = io.read(5.megabytes))
      checksum << chunk
    end

    io.rewind
    checksum.base64digest
  end

  private

  def checksum_log(message, error)
    LogStuff.warn(
      class: self.class.name,
      action: 'add_checksum',
      error: "#{error.class} - #{error.message}"
    ) { message }
  end
end
