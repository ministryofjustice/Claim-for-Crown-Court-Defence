module SeedHelper

  def self.find_or_create_caseworker!(attrs)
    if User.find_by(first_name: attrs[:first_name], last_name: attrs[:last_name], email: attrs[:email].downcase,).blank?
      # puts "+creating case worker #{attrs[:first_name]}, #{attrs[:last_name]}, #{attrs[:email]}"
      user = User.create!(
        first_name: attrs[:first_name],
        last_name:  attrs[:last_name],
        email:      attrs[:email].downcase,
        password:   ENV[attrs[:password_env_var]],
        password_confirmation: ENV[attrs[:password_env_var]]
      )
      case_worker = CaseWorker.new(role: attrs[:role])
      case_worker.user = user
      case_worker.location = Location.find_or_create_by!(name: attrs[:location].capitalize)
      case_worker.save!
    end
  end

end