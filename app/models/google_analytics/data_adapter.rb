module GoogleAnalytics
  class UnknownDataTemplate < ArgumentError; end

  class DataAdapter
    def initialize(template_id, template_data, interpolation_data = {})
      @template_id = template_id
      @template_data = template_data
      @interpolation_data = interpolation_data
      raise UnknownDataTemplate, "Unknown template '#{@template_id}'" if template.nil?
    end

    def to_s
      raise 'implement in subclasses'
    end

    def template
      templates[@template_id]
    end

    protected

    def templates
      raise 'implement in subclasses'
    end

    def template_data
      interpolate(template, interpolated_data)
    end

    def interpolated_data
      interpolate(@template_data, @interpolation_data)
    end

    def interpolate(template_hash, data)
      template_hash.each_with_object({}) do |(key, value), h|
        h[key] = value % data
      end
    end
  end
end
