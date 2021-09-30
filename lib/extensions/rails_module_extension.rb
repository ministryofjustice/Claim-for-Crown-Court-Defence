require Rails.root.join('lib', 'rails_host.rb')

module RailsModuleExtension
  def host
    RailsHost
  end
end
