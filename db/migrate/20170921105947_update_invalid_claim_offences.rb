module InvalidOffences
  def invalid_G_and_K_offences
   Offence.joins(:offence_class).where(description: [
    'Destruction of registers of births etc.',
    'Making false entries in copies of registers sent to register',
    'Possession of false identity documents',
    'Possession (with intention) of false identity documents',
    'Possession (with intention) of apparatus or material for making false identity documents',
    'Possession (without reasonable excuse) of false identity documents or apparatus or material for making false identity documents'
  ]).where.not(offence_classes: {class_letter: 'F'})
  end

  def invalid_F_and_K_offences
    Offence.joins(:offence_class).where(description: [
      'Undischarged bankrupt being concerned in a company',
      'Counterfeiting notes and coins',
      'Passing counterfeit notes and coins',
      'Offences involving custody or control of counterfeit notes and coins',
      'Making, custody or control of counterfeiting materials etc.',
      'Illegal importation: counterfeit notes or coins',
      'Fraudulent evasion: counterfeit notes or coins'
    ]).where.not(offence_classes: {class_letter: 'G'})
  end

  def claims_requiring_class_f_of_offence
    Claim::BaseClaim.joins(:offence).where(offences: { id: invalid_G_and_K_offences.pluck(:id) })
  end

  def claims_requiring_class_g_of_offence
    Claim::BaseClaim.joins(:offence).where(offences: { id: invalid_F_and_K_offences.pluck(:id) })
  end
end

class UpdateInvalidClaimOffences < ActiveRecord::Migration
  include InvalidOffences

  def up
    # update claims with invalid offences
    #
    claims_requiring_class_f_of_offence.each do |claim|
      new_offence = Offence.joins(:offence_class).where(description: claim.offence.description).where(offence_class: { class_letter: 'F' }).first
      claim.update_column(:offence_id, new_offence.id)
    end

    claims_requiring_class_g_of_offence.each do |claim|
      new_offence = Offence.joins(:offence_class).where(description: claim.offence.description).where(offence_class: { class_letter: 'G' }).first
      claim.update_column(:offence_id, new_offence.id)
    end

    # delete the invalid offences
    #
    invalid_G_and_K_offences.delete_all
    invalid_F_and_K_offences.delete_all
  end

  def down
    puts "Warning: The update of claims with invalid offences and deletion of those offences is irreversible"
    raise ActiveRecord::IrreversibleMigration
  end
end


