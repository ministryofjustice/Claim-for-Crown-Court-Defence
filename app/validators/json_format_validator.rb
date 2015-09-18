class JsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.content_type == 'application/json' && JSON.parse(File.open(value.tempfile).read)
      record.errors[attribute.to_s.capitalize] = "is either in the wrong format or contains errors"
    end
  end
end