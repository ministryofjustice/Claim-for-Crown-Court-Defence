require File.join(Rails.root, 'lib', 'rails_host.rb')

module RailsModuleExtension
  def host
    RailsHost
  end
end
