class AddVatAmountToDeterminations < ActiveRecord::Migration[4.2]
  def up
    add_column :determinations, :vat_amount, :float, default: 0.0

    Determination.all.each do |d|

      @claim = d.claim

      if @claim.apply_vat? && d.vat_amount == 0.0

        vat_amount = d.calculate_vat
        d.update_column(:vat_amount, vat_amount)

        version = d.versions.last
        if version.present?
          object_changes = version.object_changes + "\nvat_amount:\n- 0.0\n- #{vat_amount}\n"
          version.update_column(:object_changes, object_changes)
        end

      end
    end
  end

  def down
    remove_column :determinations, :vat_amount
  end

end
