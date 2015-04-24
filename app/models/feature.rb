class Feature < ActiveRecord::Base
  extend Flip::Declarable

  strategy Flip::CookieStrategy
  strategy Flip::DatabaseStrategy
  strategy Flip::DeclarationStrategy
  default false

  # Declare your features here, e.g:
  #
  # feature :world_domination,
  #   default: true,
  #   description: "Take over the world."

  feature :api,
    default: false,
    description: "basic api to for consumption by a commercial CMS (case management system)"

end
