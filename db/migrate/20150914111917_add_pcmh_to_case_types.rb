class AddPcmhToCaseTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :case_types, :allow_pcmh_fee_type, :boolean, default: false
  end
end
