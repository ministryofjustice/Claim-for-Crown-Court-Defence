class SeedAndMoveToCertificationTypes < ActiveRecord::Migration
  def change
    main_hearing                      = CertificationType.find_or_create_by!(name: 'I attended the Main Hearing (1st day of trial)', pre_may_2015: false)
    notified_court                    = CertificationType.find_or_create_by!(name: 'I notified the court, in writing before the PCMH that I was the Instructed Advocate. A copy of the letter is attached.', pre_may_2015: true)
    attended_pcmh                     = CertificationType.find_or_create_by!(name: 'I attended the PCMH (where the client was arraigned) and no other advocate wrote to the court prior to this to advice that they were the Instructed Advocate.', pre_may_2015: true)
    attended_first_hearing            = CertificationType.find_or_create_by!(name: 'I attended the first hearing after the PCMH and no other advocate attended the PCMH or wrote to the court prior to this to advise that they were the Instructed Advocate.', pre_may_2015: true)
    previous_advocate_notified_court  = CertificationType.find_or_create_by!(name: 'The previous Instructed Advocate notified the court in writing that they were no longer acting in this case and I was then instructed.', pre_may_2015: true)
    fixed_fee_case                    = CertificationType.find_or_create_by!(name: 'The case was a fixed fee (with a case number beginning with an S or A) and I attended the main hearing.', pre_may_2015: true)

    Certification.all.each do |certification|
      [:main_hearing, :notified_court, :attended_pcmh, :attended_first_hearing, :previous_advocate_notified_court, :fixed_fee_case].each do |method|
        if certification.send(method) == true
          certification_type = eval(method.to_s)
        end
      end

      c.update_column(:certification_type_id, certification_type.id)
    end

    remove_column :certifications, :main_hearing, :boolean
    remove_column :certifications, :notified_court, :boolean
    remove_column :certifications, :attended_pcmh, :boolean
    remove_column :certifications, :attended_first_hearing, :boolean
    remove_column :certifications, :previous_advocate_notified_court, :boolean
    remove_column :certifications, :fixed_fee_case, :boolean
  end
end
