class MigrateDatesAttended < ActiveRecord::Migration

  def up
    migrate_dates_for(Fee::GraduatedFee)
    migrate_dates_for(Fee::FixedFee)
  end


  private

  def migrate_dates_for(fee_class)
    fee_class.joins([:claim, :dates_attended]).includes(:dates_attended).where(claims: {type: 'Claim::LitigatorClaim'}).find_each(batch_size: 25) do |fee|
      fee.update_column(:date, fee.dates_attended.first.date)
      fee.dates_attended.destroy_all
    end
  end
end
