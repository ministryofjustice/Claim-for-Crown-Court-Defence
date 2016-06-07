module DeviseExtension
  def override_paranoid_setting(value)
    previous_value = Devise.paranoid
    Devise.paranoid = value
    result = yield
    Devise.paranoid = previous_value
    result
  end
end
