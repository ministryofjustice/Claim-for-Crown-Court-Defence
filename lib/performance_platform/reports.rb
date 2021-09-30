module PerformancePlatform
  class Reports
    def initialize
      @reports = yaml_file['reports']
    rescue NoMethodError
      raise 'config/performance_platform.yml cannot be loaded'
    end

    def call(name)
      @reports[name].symbolize_keys
    rescue NoMethodError
      raise "#{name} is not present in config/performance_platform.yml"
    end

    private

    def yaml_file
      file = Rails.root.join('config', 'performance_platform.yml')
      YAML.safe_load(ERB.new(IO.read(file)).result, [Symbol])
    end
  end
end
