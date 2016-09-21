class SupplierNumberSubModelValidator < BaseSubModelValidator

  def has_many_association_names
    [:lgfs_supplier_numbers]
  end

  def suffix_error_fields?
    false
  end

  def validate(record)
    record.errors.add(:base, :blank_supplier_numbers) if record.lgfs_supplier_numbers.empty?
    super
  end
end