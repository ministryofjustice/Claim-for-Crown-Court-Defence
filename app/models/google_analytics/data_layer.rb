module GoogleAnalytics
  class UnknownDataLayerTemplate < ArgumentError; end

  class DataLayer

    TEMPLATES = {
      virtual_page: {event: 'VirtualPageview', virtualPageURL: '%{url}', virtualPageTitle: '%{title}'}
    }.freeze


    def initialize(template_id, template_data, interpolation_data = {})
      @template_id = template_id
      @template_data = template_data
      @interpolation_data = interpolation_data
      raise UnknownDataLayerTemplate.new("Unknown template '#{@template_id}'") if template.nil?
    end

    def to_s
      "dataLayer.push(#{template_data.to_json});"
    end

    def template
      TEMPLATES[@template_id]
    end

    private

    def template_data
      interpolate(template, interpolated_data)
    end

    def interpolated_data
      interpolate(@template_data, @interpolation_data)
    end

    def interpolate(template_hash, data)
      template_hash.inject({}) { |h, (key, value)| h[key] = value % data; h }
    end
  end
end
