require_relative 'rake_helpers/s3_bucket'

namespace :canary do
  desc 'Create a new Canary factory auth token'
  task :create_factory_auth, [:memo, :flock_id] => :environment do |_task, args|
    abort 'Memo required' if args[:memo].nil?

    factory = ThinkstCanary::FactoryGenerator.new.create_factory(
      flock_id: args[:flock_id] || ENV['CANARY_FLOCK_ID'],
      memo: args[:memo]
    )
    puts "# New factory auth token (created #{Time.zone.now})"
    puts "# Memo: #{factory.memo}"
    puts "# Flock id: #{factory.flock_id}"
    puts "CANARY_FACTORY_AUTH_TOKEN=#{factory.factory_auth}"
  end

  desc 'Delete a Canary factory auth token'
  task :delete_factory_auth, [:auth_token] => :environment do |_task, args|
    abort 'No auth token given' if args[:auth_token].nil?

    factory = ThinkstCanary::Factory.new(factory_auth: args[:auth_token])
    if factory.delete
      puts "Factory auth deleted successfully"
    else
      puts "Failed to delete factory auth"
    end
  end

  desc 'Create a Canary report called reports_access_details.docx'
  task create_reports_access_details: :environment do |_task, args|
    ##################
    # Create Factory
    puts 'Opening factory'

    factory = ThinkstCanary::Factory.new(
      factory_auth: ENV['CANARY_FACTORY_AUTH_TOKEN'],
      flock_id: ENV['CANARY_FLOCK_ID']
    )

    ##################
    # Create Token
    puts 'Creating token'

    original_file = Rails.root.join('docs', 'samples', 'canary_base.docx')

    token = factory.create_token(
      kind: 'doc-msword',
      memo: "Fake reports access details file on '#{ENV['ENV']}'",
      file: File.open(original_file)
    )

    ##################
    # Fetch Token file
    puts 'Fetching token and creating report'

    Stats::StatsReport.record_start('reports_access_details').tap do |report|
      report.document.attach(
        io: StringIO.new(token.download),
        filename: 'reports_access_details.docx'
      )
      report.update(status: 'completed', completed_at: Time.zone.now)
    end
  end

  desc 'Create Canary files and upload to S3'
  task create_s3_storage_canary: :environment do |_task, args|
    host = Rails.host.env || 'localhost'
    puts "Host environment: #{host}"
    s3_bucket = S3Bucket.new(host)

    ##################
    # Create Factory
    puts 'Opening factory'

    factory = ThinkstCanary::Factory.new(
      factory_auth: ENV['CANARY_FACTORY_AUTH_TOKEN'],
      flock_id: ENV['CANARY_FLOCK_ID']
    )

    ##################
    # tmp/contents.pdf
    key = 'tmp/contents.pdf'
    puts "#{key} token"
    puts '  - creating'
    original_file = Rails.root.join('docs', 'samples', 'canary_base.pdf')
    canarytoken = factory.create_token(
      kind: 'pdf-acrobat-reader',
      memo: "#{key} in the S3 bucket for the '#{ENV['ENV']}' environment",
      file: File.open(original_file)
    )
    puts "  - uploading to #{key}"
    s3_bucket.put_object(key, canarytoken.download)

    ##################
    # admin-users.docx
    key = "admin-users.docx"
    puts "#{key} token"
    puts '  - creating'
    original_file = Rails.root.join('docs', 'samples', 'canary_base.docx')
    canarytoken = factory.create_token(
      kind: 'doc-msword',
      memo: "#{key} in the S3 bucket for the '#{ENV['ENV']}' environment",
      file: File.open(original_file)
    )
    puts "  - uploading to #{key}"
    s3_bucket.put_object(key, canarytoken.download)
  end

  desc 'Add a Canary document'
  task create_document_canary: :environment do |_task, args|
    puts 'Opening factory'
    factory = ThinkstCanary::Factory.new(
      factory_auth: ENV['CANARY_FACTORY_AUTH_TOKEN'],
      flock_id: ENV['CANARY_FLOCK_ID']
    )

    filename = "#{Faker::Name.first_name} #{Faker::Name.last_name} #{rand(100000)}"

    puts "Creating Canarytoken '#{filename}.docx' based on canary_base.docx"
    original_file = Rails.root.join('docs', 'samples', 'canary_evidence_document_base.docx')
    canarytoken_doc = factory.create_token(
      kind: 'doc-msword',
      memo: "Document '#{filename}.docx' attachment",
      file: File.open(original_file)
    )
    puts "Creating Canarytoken '#{filename}.docx.pdf' based on canary_base.pdf"
    original_file = Rails.root.join('docs', 'samples', 'canary_base.pdf')
    canarytoken_pdf = factory.create_token(
      kind: 'pdf-acrobat-reader',
      memo: "Document '#{filename}.docx.pdf' attachment preview",
      file: File.open(original_file)
    )

    doc = Document.new
    doc.document.attach(
      io: StringIO.new(canarytoken_doc.download),
      filename: "#{filename}.docx"
    )
    doc.converted_preview_document.attach(
      io: StringIO.new(canarytoken_pdf.download),
      filename: "#{filename}.docx.pdf"
    )
    doc.save
    puts "Update Canarytoken memo to; Document '#{filename}.docx' [id: #{doc.id}] attachment on '#{ENV['ENV']}'"
    canarytoken_doc.memo = "Document '#{filename}.docx' [id: #{doc.id}] attachment on '#{ENV['ENV']}'"
    puts "Update Canarytoken memo to; Document '#{filename}.docx.pdf' [id: #{doc.id}] attachment preview on '#{ENV['ENV']}'"
    canarytoken_pdf.memo = "Document '#{filename}.docx.pdf' [id: #{doc.id}] attachment preview on '#{ENV['ENV']}'"
  end

  desc 'List unattached documents and messages'
  task :find_unattached, [:type] => :environment do |_task, args|
    require_relative './rake_helpers/canary_checker'

    RakeHelpers::CanaryChecker.new(args[:type]).display
  end
end
