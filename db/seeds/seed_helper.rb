module SeedHelper

  def self.find_or_create_caseworker!(attrs)
    if User.find_by(first_name: attrs[:first_name], last_name: attrs[:last_name], email: attrs[:email].downcase).blank?
      # puts "+creating case worker #{attrs[:first_name]}, #{attrs[:last_name]}, #{attrs[:email]}"
      user = User.create!(
        first_name: attrs[:first_name],
        last_name:  attrs[:last_name],
        email:      attrs[:email].downcase,
        password:   ENV.fetch(attrs[:password_env_var]),
        password_confirmation: ENV[attrs[:password_env_var]]
      )
      case_worker = CaseWorker.new(roles: attrs[:roles], days_worked: attrs[:days_worked])
      case_worker.user = user
      case_worker.location = Location.find_or_create_by!(name: attrs[:location].capitalize)
      case_worker.save!
    end
  end

  # NOTE: since provider roles are serialized we cannot used standard find_or_create_by activerrecord helper
  def self.find_or_create_provider!(attrs)
    provider = Provider.find_by(name: attrs[:name])
    if provider.blank?
      provider = Provider.create!(
        name: attrs[:name],
        supplier_number: attrs[:supplier_number],
        api_key: attrs[:api_key],
        provider_type: attrs[:provider_type],
        vat_registered: attrs[:vat_registered],
        roles: attrs[:roles]
      )
    end
    provider
  end

end
