class RemoveObsoleteAttributesFromCertification < ActiveRecord::Migration
  def up
    remove_column :certifications, :main_hearing, :boolean
    remove_column :certifications, :notified_court, :boolean
    remove_column :certifications, :attended_pcmh, :boolean
    remove_column :certifications, :attended_first_hearing, :boolean
    remove_column :certifications, :previous_advocate_notified_court, :boolean
    remove_column :certifications, :fixed_fee_case, :boolean
  end

  def down
    add_column :certifications, :main_hearing, :boolean
    add_column :certifications, :notified_court, :boolean
    add_column :certifications, :attended_pcmh, :boolean
    add_column :certifications, :attended_first_hearing, :boolean
    add_column :certifications, :previous_advocate_notified_court, :boolean
    add_column :certifications, :fixed_fee_case, :boolean

    Certification.all.each do | c |

      @old_certifed_as = c.certified_as

      if @old_certifed_as == 1 then
        c.update_attribute(:main_hearing, true)
      else
        c.update_attribute(:main_hearing, false)
      end

      if @old_certifed_as == 2 then
        c.update_attribute(:notified_court, true)
      else
        c.update_attribute(:notified_court, false)
      end

      if @old_certifed_as == 3 then
        c.update_attribute(:attended_pcmh, true)
      else
        c.update_attribute(:attended_pcmh, false)
      end

      if @old_certifed_as == 4 then
        c.update_attribute(:attended_first_hearing, true)
      else
        c.update_attribute(:attended_first_hearing, false)
      end

      if @old_certifed_as == 5 then
        c.update_attribute(:previous_advocate_notified_court, true)
      else
        c.update_attribute(:previous_advocate_notified_court, false)
      end

      if @old_certifed_as == 6 then
        c.update_attribute(:fixed_fee_case, true)
      else
        c.update_attribute(:fixed_fee_case, false)
      end

    end

  end

end
