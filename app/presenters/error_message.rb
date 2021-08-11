# frozen_string_literal: true

module ErrorMessage
  def self.translation_file_for(model_name)
    Rails.root.join('config', 'locales', I18n.locale.to_s, 'error_messages', "#{model_name}.yml")
  end

  def self.default_translation_file
    translation_file_for('claim')
  end
end
