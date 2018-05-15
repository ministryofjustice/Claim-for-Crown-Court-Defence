module StrongParamHelpers
  def strong_params(weak_params)
    ActionController::Parameters.new(weak_params).permit!
  end
end
