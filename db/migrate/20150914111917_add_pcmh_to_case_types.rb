class AddPcmhToCaseTypes < ActiveRecord::Migration
  def change
    add_column :case_types, :allow_pcmh_fee_type, :boolean, default: false
  end
end
