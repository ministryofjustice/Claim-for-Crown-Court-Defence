class ModifyFeeTypeCaseUplift < ActiveRecord::Migration[4.2]
  # repurpose LGFS case uplift as defendant uplift
  # NOTE: smoke test on dev build of branch means we
  # need to cater for type not existing
  def up
    Fee::MiscFeeType
      .where(unique_code: 'MIUPL')
      .update_all(description: 'Defendant uplift')
  end

  def down
    Fee::MiscFeeType
      .where(unique_code: 'MIUPL')
      .update_all(description: 'Case uplift')
  end
end
