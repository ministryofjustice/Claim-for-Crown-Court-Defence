require 'grape'
require 'grape-swagger'

module API

  class Root < Grape::API
    use API::Logger
    mount API::V1::Advocates::Root

    # Set the papertrail user 'whodunnit' attribute.
    # Normally 'Advocate' or 'Caseworker' via the front-end.
    before do
      set_papertrail_user('API')
    end
  end
end
