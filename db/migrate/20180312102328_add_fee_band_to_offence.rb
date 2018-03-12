class AddFeeBandToOffence < ActiveRecord::Migration
  def change
    add_reference :offences, :fee_band, index: true, foreign_key: true
  end
end
