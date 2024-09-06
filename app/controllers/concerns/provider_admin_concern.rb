module ProviderAdminConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_provider, only: %i[show edit update]
  end

  private

  def build_associations
    @provider.supplier_numbers.build if @provider.supplier_numbers.none?
  end

  def provider_params
    params.require(:provider).permit(
      :name,
      :provider_type,
      :firm_agfs_supplier_number,
      :vat_registered,
      roles: [],
      lgfs_supplier_numbers_attributes: %i[
        id
        provider_id
        supplier_number
        name
        postcode
        _destroy
      ]
    )
  end

  def filtered_params
    []
  end
end
