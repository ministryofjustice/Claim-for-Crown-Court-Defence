# == Schema Information
#
# Table name: features
#
#  id         :integer          not null, primary key
#  key        :string(255)      not null
#  enabled    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
    default: false, #change to true to switch the api on
    description: "Basic api to for consumption by a commercial CMS (case management system)"
end
