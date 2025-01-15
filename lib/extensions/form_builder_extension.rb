module Extensions
  module FormBuilderExtension
    def as_json(options = {})
      options[:except].present? ? options[:except] << 'template' : options[:except] = ['template']

      super.as_json(options)
    end
  end
end
