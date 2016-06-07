require 'grape'
require 'grape-swagger'

module API
  class Root < Grape::API
    use API::Logger
    mount API::V1::ExternalUsers::Root

    # Set the papertrail user 'whodunnit' attribute.
    # Normally 'ExternalUser' or 'Caseworker' via the front-end.
    before do
      set_papertrail_user('API')
    end
  end
end
