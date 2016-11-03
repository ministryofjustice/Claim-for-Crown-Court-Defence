module SeedHelper

  def self.find_or_create_caseworker!(attrs)
    user = User.active.find_by(email: attrs[:email].downcase)
    if user.blank?
      user = User.create!(
        first_name: attrs[:first_name],
        last_name:  attrs[:last_name],
        email:      attrs[:email].downcase,
        password:   ENV.fetch(attrs[:password_env_var]),
        password_confirmation: ENV[attrs[:password_env_var]]
      )
      case_worker = CaseWorker.new(roles: attrs[:roles])
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
        firm_agfs_supplier_number: attrs[:firm_agfs_supplier_number],
        api_key: attrs[:api_key],
        provider_type: attrs[:provider_type],
        vat_registered: attrs[:vat_registered],
        roles: attrs[:roles],
        lgfs_supplier_numbers: attrs[:lgfs_supplier_numbers] || []
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

  def self.find_or_create_expense_type!(record_id, name, roles, reason_set, code)
    expense_type = ExpenseType.find_by(id: record_id)

    if expense_type.nil?
      expense_type = ExpenseType.create!(id: record_id, name: name, roles: roles, reason_set: reason_set, unique_code: code)
    elsif expense_type.name != name
      raise "Unexpected name for ExpenseType #{expense_type.id}: Expected #{name}, got #{expense_type.name}"
    end

    if expense_type.unique_code.blank?
      expense_type.update(unique_code: code)
    end

    expense_type
  end

  def self.find_or_create_disbursement_type!(record_id, code, name)
    disbursement_type = DisbursementType.find_by(id: record_id)

    if disbursement_type.nil?
      disbursement_type = DisbursementType.create!(id: record_id, unique_code: code, name: name)
    elsif disbursement_type.name != name
      raise "Unexpected name for DisbursementType #{disbursement_type.id}: Expected #{name}, got #{disbursement_type.name}"
    end

    if disbursement_type.unique_code.blank?
      disbursement_type.update(unique_code: code)
    end

    disbursement_type
  end

  def self.build_supplier_numbers(supplier_numbers)
    supplier_numbers.map do |number|
      SupplierNumber.find_or_initialize_by(supplier_number: number)
    end
  end
end
