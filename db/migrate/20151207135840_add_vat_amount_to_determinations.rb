class AddVatAmountToDeterminations < ActiveRecord::Migration
  def up
    add_column :determinations, :vat_amount, :float, default: 0.0

    Determination.all.each do |d|

      @claim = d.claim

      if @claim.apply_vat? && d.vat_amount == 0.0
        vat_amount = d.calculate_vat
        d.update_column(:vat_amount, vat_amount)
      end
    end
  end

  def down
    remove_column :determinations, :vat_amount
  end

end
