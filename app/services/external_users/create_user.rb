module ExternalUsers
  class CreateUser
    def initialize(user)
      @user = user
    end

    def call!
      ExternalUser.transaction do
        lgfs_supplier_number = SupplierNumber.new(supplier_number: format('9X%03dX', generate_lgfs_supplier_number))
        provider = create_provider!(lgfs_supplier_number)
        create_external_user!(provider)
      end
    end

    private

    attr_reader :user

    def create_provider!(lgfs_supplier_number)
      Provider.create!(
        # NOTE: not sure why the provider name is using
        # Faker (preserving functionality though :S)
        name: Faker::Company.name,
        firm_agfs_supplier_number: generate_unique_supplier_number,
        provider_type: 'firm',
        roles: %w[agfs lgfs],
        vat_registered: false,
        lgfs_supplier_numbers: [lgfs_supplier_number]
      )
    end

    def create_external_user!(provider)
      external_user = ExternalUser.new(
        provider: provider,
        roles: ['admin'],
        supplier_number: generate_unique_supplier_number
      )
      external_user.user = user
      external_user.save!
    end

    def generate_lgfs_supplier_number
      last_record = SupplierNumber.where("supplier_number LIKE '9X%'").reorder(:supplier_number).last
      return 1 unless last_record
      /^9X(?<highest_number>^.*)X$/ =~ last_record.supplier_number
      highest_number.to_i + 1
    end

    def generate_unique_supplier_number
      # NOTE: failing to understand how this guarantees
      # uniqueness (preserving functionality though :S)
      alpha_part = ''
      2.times { alpha_part << rand(65..89).chr }
      numeric_part = rand(999)
      "#{alpha_part}#{format('%03d', numeric_part)}"
    end
  end
end
