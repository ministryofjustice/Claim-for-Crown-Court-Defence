class S3ZipDownloader
  require 'zip'

  def initialize(claim)
    @claim = claim
    @folder = Dir.mktmpdir("#{@claim.case_number}-", './tmp')
    move_files
    @files_to_zip = Dir.entries(@folder) - %w[. ..]
    @zip_file = Tempfile.new([@claim.case_number, '.zip'], './tmp')
  end

  def generate!
    return_zip = zip_files
    FileUtils.rm_rf(@folder)
    return_zip
  end

  private

  def zip_files
    Zip::File.new(@zip_file, Zip::File::CREATE) do |zip_file|
      @files_to_zip.each do |filename|
        puts "adding '#{File.join(@folder, filename)}' to '#{@zip_file.path}'"
        zip_file.add(filename, File.join(@folder, filename))
      end
    end
  end

  def move_files
    send("move_files_from_#{Paperclip::Attachment.default_options[:storage]}")
  end

  def move_files_from_filesystem
    @claim.documents.each do |file|
      FileUtils.copy(file.file_path, @folder)
    end
  end

  def move_files_from_s3
    s3 = Aws::S3::Resource.new(region: 'eu-west-1')
    bucket = s3.bucket(ENV['adp-bucket-name'])
    @claim.documents.each do |file|
      file_obj = bucket.object(file.file_path)
      file_obj.get(response_target: "#{@folder}/#{file}")
    end
  end
end
