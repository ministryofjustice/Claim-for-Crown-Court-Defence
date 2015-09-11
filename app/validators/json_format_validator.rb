class JsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.rewind # incase the file has already been read elsewhere
    unless JSON.parse(value.read)
      record.errors[attribute] << ("is either in the wrong format or contains errors")
    end
  end
end