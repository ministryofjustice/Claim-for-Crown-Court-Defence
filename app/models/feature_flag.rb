class FeatureFlag < ApplicationRecord
  def self.enable_new_monarch?
    feature_flag.enable_new_monarch
  end

  def self.feature_flag
    FeatureFlag.first || FeatureFlag.create!
  end
end
