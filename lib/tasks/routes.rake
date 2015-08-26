# lib/tasks/routes.rake
namespace :api do
  desc "API Routes"
  task :routes => :environment do
    API::V1::Advocates::Root.routes.each do |api|
      method = api.route_method.ljust(10)
      if !api.route_version.nil?
        path = api.route_path.gsub(":version", api.route_version)
        puts "     #{method} #{path}"
      end
    end
  end
end
