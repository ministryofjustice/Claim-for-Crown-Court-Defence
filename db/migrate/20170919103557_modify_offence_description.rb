class ModifyOffenceDescription < ActiveRecord::Migration[4.2]
  # fix typo
  def up
    Offence
      .where(description: 'Possession of false identify documents')
      .update_all(description: 'Possession of false identity documents')
  end

  # reinstate typo
  def down
    Offence
      .where(description: 'Possession of false identity documents')
      .update_all(description: 'Possession of false identify documents')
  end
end
