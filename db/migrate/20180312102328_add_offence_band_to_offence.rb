class AddOffenceBandToOffence < ActiveRecord::Migration[4.2]
  def change
    add_reference :offences, :offence_band, index: true, foreign_key: true
  end
end
