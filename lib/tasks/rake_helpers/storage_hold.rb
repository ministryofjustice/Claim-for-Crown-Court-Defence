class Storage
  ATTACHMENTS = {
    stats_reports: ['documents'],
    messages: ['attachment'],
    documents: ['document', 'converted_preview_document']
  }.freeze

  MODELS = {
    stats_reports: Stats::StatsReport,
    message: Message,
    document: Document
  }

  def initialize
    @connection = ActiveRecord::Base.connection.raw_connection
  end

  def self.make_dummy_files_for model
    if MODELS[model].nil?
      puts "Cannot create dummy files for: #{args[:model]}"
      exit
    end

    ATTACHMENTS[model].each do |name|
      records = MODELS[model].where.not("#{name}_file_name" => nil)

      bar = self.progress_bar title: name, total: records.count

      records.each do |record|
        bar.increment
        filename = File.absolute_path(record.send(name).path)
        FileUtils.mkdir_p File.dirname(filename)
        File.open(filename, 'wb') { |file| file.write(SecureRandom.random_bytes(record.send("#{name}_file_size"))) }
      end
    end
  end

  def self.set_checksums(records:, attachments:, model:)
    ATTACHMENT[model].each do |name|
      bar = self.progress_bar title: name, total: records.count

      records.each do |record|
        bar.increment
        record.update("as_#{name}_checksum": self.compute_checksum_in_chunks(record.send(name)))
      end
    end
  end

  # Copied from https://github.com/rails/rails/blob/main/activestorage/app/models/active_storage/blob.rb
  def self.compute_checksum_in_chunks(attachment)
    io = Paperclip.io_adapters.for(attachment)

    Digest::MD5.new.tap do |checksum|
      while chunk = io.read(5.megabytes)
        checksum << chunk
      end

      io.rewind
    end.base64digest
  rescue Errno::ENOENT
    'FileMissing'
  end

  def self.progress_bar(title:, total:)
    ProgressBar.create(
      title: title,
      format: "%a [%e] %b\u{15E7}%i %c/%C",
      progress_mark: '#'.green,
      remainder_mark: "\u{FF65}".yellow,
      starting_at: 0,
      total: total
    )
  end
end