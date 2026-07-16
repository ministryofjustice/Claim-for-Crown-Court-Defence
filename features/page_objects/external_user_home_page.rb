require_relative "user_home_page"

class ExternalUserHomePage < UserHomePage
  set_url "/external_users"
  set_url_matcher %r{/external_users(/claims)?$}
end
