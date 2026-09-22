require 'rainbow'

module SeedHelper
  class << self
    def update_or_create_case_stage!(options)
      stage = CaseStage.find_by(id: options[:id])
      if stage
        Rails.logger.info "Updating case_stage #{stage.description}: #{options}"
        stage.update!(options)
      else
        Rails.logger.info "Creating case_stage: #{options}"
        stage = CaseStage.create!(options)
      end
      stage
    end

    # unique_code has unique, not null contraint but cannot be given
    # expected value until all offences seeded
    # - see DataMigrator::OffenceUniqueCodeMigrator
    # NOTE: does not create the OffenceFeeScheme join - callers are responsible for that
    def find_or_create_scheme_10_offence!(attrs)
      offence = Offence.find_by(attrs)
      offence = Offence.create!(attrs.merge(unique_code: SecureRandom.uuid)) if offence.blank?
      offence
    end

    # unique_code has unique, not null contraint but cannot be given
    # expected value until all offences seeded
    # - see DataMigrator::OffenceUniqueCodeMigrator
    # NOTE: does not create the OffenceFeeScheme join - callers are responsible for that
    def find_or_create_scheme_11_offence!(attrs)
      offence = Offence.where(id: 3000..4500).find_by(attrs)
      offence = Offence.create!(attrs.merge(unique_code: SecureRandom.uuid)) if offence.blank?
      offence
    end

    # Duplicates each offence in `source_offences` as a new Offence record linked to
    # `fee_scheme`, deriving each copy's unique_code by yielding the original to the given
    # block. Used when a new fee scheme needs its own offence records (e.g. because the
    # unique_code format changes), as opposed to simply linking the existing offences to
    # the new scheme via OffenceFeeScheme (see FeeScheme#offences usage elsewhere in
    # db/seeds/schemas/*.rb for that simpler, more common case).
    #
    # Uses bulk insert_all rather than one Offence.create! per offence (which is what
    # `source_offences.each { |o| o.dup.tap { |n| ... }.save! }` amounts to) - for a fee
    # scheme with ~1300 offences that is the difference between a handful of queries and
    # several thousand. This bypasses Offence validations/callbacks, so it must only be
    # given attributes already known to be valid (i.e. offences read back out of the DB).
    #
    # Returns the number of offences copied.
    def bulk_duplicate_offences!(source_offences, fee_scheme:)
      source_offences = source_offences.to_a
      return 0 if source_offences.empty?

      now = Time.current
      rows = source_offences.map do |offence|
        offence.attributes.except('id', 'created_at', 'updated_at').merge(
          'unique_code' => yield(offence.unique_code),
          'created_at' => now,
          'updated_at' => now
        )
      end

      new_ids = Offence.insert_all(rows, returning: %w[id]).rows.flatten
      OffenceFeeScheme.insert_all(new_ids.map { |id| { offence_id: id, fee_scheme_id: fee_scheme.id } })
      new_ids.size
    end

    def find_or_create_caseworker!(attrs)
      user = User.active.find_by(email: attrs[:email].downcase)
      if user.blank?
        user = User.create!(
          first_name: attrs[:first_name],
          last_name: attrs[:last_name],
          email: attrs[:email].downcase,
          password: ENV.fetch(attrs[:password_env_var]),
          password_confirmation: ENV.fetch(attrs[:password_env_var])
        )
        case_worker = CaseWorker.new(roles: attrs[:roles])
        case_worker.user = user
        case_worker.location = Location.find_or_create_by!(name: attrs[:location].capitalize)
        case_worker.save!
      end
      user.persona
    end

    # NOTE: since provider roles are serialized we cannot used standard find_or_create_by activerrecord helper
    def find_or_create_provider!(attrs)
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
    def find_or_create_fee_type!(klass, attrs)
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

    def find_or_create_expense_type!(record_id, name, roles, reason_set, code)
      expense_type = ExpenseType.find_by(id: record_id)

      if expense_type.nil?
        expense_type = ExpenseType.create!(id: record_id, name: name, roles: roles, reason_set: reason_set, unique_code: code)
      elsif expense_type.name != name
        raise "Unexpected name for ExpenseType #{expense_type.id}: Expected #{name}, got #{expense_type.name}"
      end

      expense_type.update(unique_code: code) if expense_type.unique_code.blank?
      expense_type
    end

    def find_or_create_disbursement_type!(record_id, code, name, deleted_at=nil)
      disbursement_type = DisbursementType.find_by(id: record_id)

      if disbursement_type.nil?
        disbursement_type = DisbursementType.create!(id: record_id, unique_code: code, name: name, deleted_at: deleted_at)
      elsif disbursement_type.name != name
        raise "Unexpected name for DisbursementType #{disbursement_type.id}: Expected #{name}, got #{disbursement_type.name}"
      end

      disbursement_type.update(unique_code: code) if disbursement_type.unique_code.blank?
      disbursement_type.update(deleted_at: deleted_at) if disbursement_type.deleted_at.blank? && deleted_at
      disbursement_type
    end

    def build_supplier_numbers(supplier_numbers)
      supplier_numbers.map do |number|
        SupplierNumber.find_or_initialize_by(supplier_number: number)
      end
    end
  end
end
