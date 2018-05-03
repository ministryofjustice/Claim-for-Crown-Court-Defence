class SeedAndMoveToCertificationTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_types, :roles, :string

    list = [
      {
        name: 'I attended the Main Hearing (1st day of trial)',
        pre_may_2015: false,
        roles: ['agfs']
      },
      {
        name: 'I notified the court, in writing before the PCMH that I was the Instructed Advocate. A copy of the letter is attached.',
        pre_may_2015: true,
        roles: ['agfs']
      },
      {
        name: 'I attended the PCMH (where the client was arraigned) and no other advocate wrote to the court prior to this to advice that they were the Instructed Advocate.',
        pre_may_2015: true,
        roles: ['agfs']
      },
      {
        name: 'I attended the first hearing after the PCMH and no other advocate attended the PCMH or wrote to the court prior to this to advise that they were the Instructed Advocate.',
        pre_may_2015: true,
        roles: ['agfs']
      },
      {
        name: 'The previous Instructed Advocate notified the court in writing that they were no longer acting in this case and I was then instructed.',
        pre_may_2015: true,
        roles: ['agfs']
      },
      {
        name: 'The case was a fixed fee (with a case number beginning with an S or A) and I attended the main hearing.',
        pre_may_2015: true,
        roles: ['agfs']
      }
    ]

    list.each do |data|
      CertificationType.find_or_create_by!(name: data.delete(:name)) do |c|
        c.pre_may_2015 = data[:pre_may_2015]
        c.roles = data[:roles]
      end
    end

    Certification.all.each do |certification|
      certification_type = nil

      [:main_hearing, :notified_court, :attended_pcmh, :attended_first_hearing, :previous_advocate_notified_court, :fixed_fee_case].each do |method|
        if certification.send(method) == true
          certification_type = eval(method.to_s)
        end
      end

      certification.update_column(:certification_type_id, certification_type.id)
    end

    remove_column :certifications, :main_hearing, :boolean
    remove_column :certifications, :notified_court, :boolean
    remove_column :certifications, :attended_pcmh, :boolean
    remove_column :certifications, :attended_first_hearing, :boolean
    remove_column :certifications, :previous_advocate_notified_court, :boolean
    remove_column :certifications, :fixed_fee_case, :boolean
  end
end
