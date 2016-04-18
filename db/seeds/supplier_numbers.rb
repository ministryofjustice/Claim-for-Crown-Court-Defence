providers = YAML::load_file(Rails.root.join('lib', 'assets', 'data', 'supplier_numbers.yml'))

providers.each do |provider_name, supplier_numbers|
  if (provider = Provider.find_by_name(provider_name))
    supplier_numbers.each do |number|
      SupplierNumber.find_or_create_by!(supplier_number: number, provider_id: provider.id)
    end
  end
end
