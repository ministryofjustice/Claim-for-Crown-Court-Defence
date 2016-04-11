Before('@stub_s3_upload') do
  stub_request(:put, /shorter_lorem\.docx/)
end
