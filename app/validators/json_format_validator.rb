class JsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      JSON.parse(File.open(value.tempfile).read)
    rescue
      record.errors[attribute.to_s.capitalize] = "is either not JSON or contains errors"
    end
  end
end
