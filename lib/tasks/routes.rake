namespace :api do
  desc "API Routes"
  task :routes => :environment do
    API::V1::ExternalUsers::Root.routes.each do |api|
      method = api.route_method.ljust(10)
      path = api.route_path.sub('(.:format)', '')
      version = api.route_version
      puts " #{version}   #{method} #{path}"
    end
  end
end
