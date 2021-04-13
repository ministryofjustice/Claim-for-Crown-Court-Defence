class S3ZipDownloader
  require 'zip'

  def initialize(claim)
    @claim = claim
    @folder = Dir.mktmpdir("#{@claim.case_number}-", './tmp')
    move_files
    @files_to_zip = Dir.entries(@folder) - %w[. ..]
    @zip_file = "./tmp/#{@claim.case_number}-#{SecureRandom.uuid}-documents.zip"
  end

  def generate!
    zip_files
    FileUtils.rm_rf(@folder)
    @zip_file
  end

  private

  def zip_files
    Zip::File.open(@zip_file, Zip::File::CREATE) do |zip_file|
      @files_to_zip.each do |filename|
        zip_file.add(filename, File.join(@folder, filename))
      end
    end
  end

  def move_files
    @claim.documents.each do |file|
      FileUtils.copy(Paperclip.io_adapters.for(file.document).path, @folder)
    end
  end
end
