# == Schema Information
#
# Table name: certifications
#
#  id                               :integer          not null, primary key
#  claim_id                         :integer
#  main_hearing                     :boolean
#  notified_court                   :boolean
#  attended_pcmh                    :boolean
#  attended_first_hearing           :boolean
#  previous_advocate_notified_court :boolean
#  fixed_fee_case                   :boolean
#  certified_by                     :string(255)
#  certification_date               :date
#  created_at                       :datetime
#  updated_at                       :datetime
#

FactoryGirl.define do
  factory :certification do
    main_hearing                        true
    notified_court                      false
    attended_pcmh                       false
    attended_first_hearing              false
    previous_advocate_notified_court    false
    fixed_fee_case                      false
    certified_by                        'Stepriponikas Bonstart'
    certification_date                  Date.today


    trait :notified_court do
      main_hearing    false
      notified_court  true
    end

    trait :attended_pcmh do
      main_hearing    false
      attended_pcmh   true
    end
  end

end
