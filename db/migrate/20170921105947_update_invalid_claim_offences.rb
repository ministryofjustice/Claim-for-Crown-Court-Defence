module InvalidOffences
  def invalid_offence_G_and_K_ids
   Offence.joins(:offence_class).where(description: [
    'Destruction of registers of births etc.',
    'Making false entries in copies of registers sent to register',
    'Possession of false identity documents',
    'Possession (with intention) of false identity documents',
    'Possession (with intention) of apparatus or material for making false identity documents',
    'Possession (without reasonable excuse) of false identity documents or apparatus or material for making false identity documents',
  ]).where.not(offence_classes: {class_letter: 'F'}).pluck(:id)
  end

  def invalid_offence_F_and_K_ids
    Offence.joins(:offence_class).where(description: [
      'Undischarged bankrupt being concerned in a company',
      'Counterfeiting notes and coins',
      'Passing counterfeit notes and coins',
      'Offences involving custody or control of counterfeit notes and coins',
      'Making, custody or control of counterfeiting materials etc.',
      'Illegal importation: counterfeit notes or coins',
      'Fraudulent evasion: counterfeit notes or coins'
    ]).where.not(offence_classes: {class_letter: 'G'}).pluck(:id)
  end

  def claims_requiring_class_f_of_offence
    Claim::BaseClaim.joins(:offence).where(offences: {id: invalid_offence_G_and_K_ids })
  end

  def claims_requiring_class_g_of_offence
      Claim::BaseClaim.joins(:offence).where(offences: {id: invalid_offence_F_and_K_ids })
  end
end

class UpdateInvalidClaimOffences < ActiveRecord::Migration
  include InvalidOffences

  def up
    claims_requiring_class_f_of_offence.each do |claim|
      new_offence = Offence.joins(:offence_class).where(description: claim.offence.description).where(offence_class: { class_letter: 'F' }).first
      claim.update_column(:offence_id, new_offence.id)
    end

    claims_requiring_class_g_of_offence.each do |claim|
      new_offence = Offence.joins(:offence_class).where(description: claim.offence.description).where(offence_class: { class_letter: 'G' }).first
      claim.update_column(:offence_id, new_offence.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end


