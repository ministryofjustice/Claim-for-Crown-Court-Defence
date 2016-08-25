namespace :api do
  desc "API Routes"
  task :routes => :environment do
    API::V1::ExternalUsers::Root.routes.each do |api|
      method = api.request_method.ljust(10)
      path = api.path.sub('(.:format)', '')
      version = api.version
      puts " #{version}   #{method} #{path}"
    end
  end
end
