class AddFeeBandToOffence < ActiveRecord::Migration
  def change
    add_reference :offences, :offence_band, index: true, foreign_key: true
  end
end
