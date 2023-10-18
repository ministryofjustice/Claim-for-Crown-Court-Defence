require Rails.root.join('lib', 'rails_host.rb')

module Extensions
  module RailsModuleExtension
    def host
      RailsHost
    end
  end
end
