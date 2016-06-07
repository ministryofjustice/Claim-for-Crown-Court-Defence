# == Schema Information
#
# Table name: certification_types
#
#  id           :integer          not null, primary key
#  name         :string
#  pre_may_2015 :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#  roles        :string
#
FactoryGirl.define do
  factory :certification_type do
    name { Faker::Lorem.sentence }
    pre_may_2015 false
    roles ['agfs']

    trait :lgfs do
      name 'LGFS certification type'
      roles ['lgfs']
    end

    trait :pre_may do
      pre_may_2015 true
    end

    trait :type_1 do
      name 'I attended the Main Hearing (1st day of trial)'
    end

    trait :type_2 do
      name 'I notified the court, in writing before the PCMH that I was the Instructed Advocate. <br/>A copy of the letter is attached.'
    end

    trait :type_3 do
      name 'I attended the PCMH (where the client was arraigned) and no other advocate wrote to the court prior to this to advice that they were the Instructed Advocate.'
    end

    trait :type_4 do
      name 'I attended the first hearing after the PCMH and no other advocate attended the PCMH or wrote to the court prior to this to advise that they were the Instructed Advocate.'
    end

    trait :type_5 do
      name 'The previous Instructed Advocate notified the court in writing that they were no longer acting in this case and I was then instructed.'
    end

    trait :type_6 do
      name 'The case was a fixed fee (with a case number beginning with an S or A) and I attended the main hearing.'
    end
  end
end
