module XmlMiniExtension
  # Rails 4.x doesn't provide any mechanism to configure the output of `nil` attributes when serializing to XML.
  # This patch will make it possible to change `nil` attributes from being serialized as `<submitted_at nil="true"/>`
  # and instead being omitted or serialized as empty strings.
  #
  def to_tag(key, value, options)
    if value.nil?
      return if options[:skip_nils]
      value = '' if options[:blank_nils]
    end
    super
  end
end
