module SeedHelper

  def self.find_or_create_caseworker!(attrs)
    user = User.find_by(first_name: attrs[:first_name], last_name: attrs[:last_name], email: attrs[:email].downcase)
    if user.blank?
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
    user.persona
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

  # NOTE: since fee type roles are serialized we cannot used standard find_or_create_by activerrecord helper
  def self.find_or_create_fee_type!(klass, attrs)
    fee_type = klass.find_by(description: attrs[:description])
    if fee_type.blank?
      fee_type = klass.create!(
        description: attrs[:description],
        code: attrs[:code],
        max_amount: attrs[:max_amount],
        calculated: attrs[:calculated],
        type: klass.to_s,
        roles: attrs[:roles]
      )
    end
    fee_type
  end

  # NOTE: since expense type roles are serialized we cannot used standard find_or_create_by activerrecord helper
  def self.find_or_create_expense_type!(name, roles, reason_set)
    expense_type = ExpenseType.where('name ILIKE ?', name).first
    if expense_type.nil?
      expense_type = ExpenseType.create!(name: name, roles: roles, reason_set: reason_set)
    end
    expense_type
  end
end
