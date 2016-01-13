class SetCertificationTypeIdInCertification < ActiveRecord::Migration
  def up
    Certification.all.each do | c |

      @new_certification_type_id = 0

      if c.main_hearing == true then
        @new_certification_type_id = 1
      elsif c.notified_court == true then
        @new_certification_type_id = 2
      elsif c.attended_pcmh == true then
        @new_certification_type_id = 3
      elsif c.attended_first_hearing == true then
        @new_certification_type_id = 4
      elsif c.previous_advocate_notified_court == true then
        @new_certification_type_id = 5
      elsif c.fixed_fee_case == true then
        @new_certification_type_id = 6
      end

      c.update_attribute(:certification_type_id, @new_certification_type_id)
    end
  end

  def down
    Certification.update_all(:certification_type_id, '')
  end

end
