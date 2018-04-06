class ModifyFeeTypeCaseUplift < ActiveRecord::Migration
  # repurpose LGFS case uplift as defendant uplift
  #
  def up
    Fee::MiscFeeType
      .find_by(unique_code: 'MIUPL')
      .update(description: 'Defendant uplift')
  end

  def down
    Fee::MiscFeeType
      .find_by(unique_code: 'MIUPL')
      .update(description: 'Case uplift')
  end
end
