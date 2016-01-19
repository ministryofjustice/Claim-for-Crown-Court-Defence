# == Schema Information
#
# Table name: certificate_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  pre_may_2015                     :boolean
#  created_at              :datetime
#  updated_at              :datetime

FactoryGirl.define do
  factory :certification_type do

    #id, name
    #1, I attended the Main Hearing (1st day of trial)
    #2, I notified the court, in writing before the PCMH that I was the Instructed Advocate. <br/>A copy of the letter is attached.
    #3, I attended the PCMH (where the client was arraigned) and no other advocate wrote to the court prior to this to advice that they were the Instructed Advocate.
    #4, I attended the first hearing after the PCMH and no other advocate attended the PCMH or wrote to the court prior to this to advise that they were the Instructed Advocate.
    #5, The previous Instructed Advocate notified the court in writing that they were no longer acting in this case and I was then instructed.
    #6, The case was a fixed fee (with a case number beginning with an S or A) and I attended the main hearing.


    name 'I attended the Main Hearing (1st day of trial)'
  end
end
