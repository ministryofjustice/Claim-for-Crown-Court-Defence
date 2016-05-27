# == Schema Information
#
# Table name: fee_types
#
#  id          :integer          not null, primary key
#  description :string
#  code        :string
#  created_at  :datetime
#  updated_at  :datetime
#  max_amount  :decimal(, )
#  calculated  :boolean          default(TRUE)
#  type        :string
#  roles       :string
#  parent_id   :integer
#

FactoryGirl.define do
  factory :basic_fee_type, class: Fee::BasicFeeType do
    sequence(:description) { |n| "AGFS, Basic fee type, basic fee -#{n}" }
    code { random_safe_code }
    calculated true
    roles ['agfs']

    trait :ppe do
      description 'Pages of prosecution evidence'
      code 'PPE'
      calculated false
    end

    trait :npw do
      description 'Number of prosecution witnesses'
      code 'NPW'
      calculated false
    end

    trait :lgfs do
      roles ['lgfs']
    end

    trait :both_fee_schemes do
      roles ['lgfs', 'agfs']
    end

    trait :hsts do
      description 'Hearing subsequent to sentence'
      roles [ 'lgfs' ]
    end

    factory :misc_fee_type, class: Fee::MiscFeeType do
      sequence(:description) { |n| "AGFS, Misc fee type, Noting brief - #{n}" }
      code { random_safe_code }
      calculated true
      roles ['agfs']

      trait :lgfs do
        sequence(:description) { |n| "LGFS, Misc fee type, Special preparation fee - #{n}" }
        calculated false
        roles ['lgfs']
      end
    end

    factory :fixed_fee_type, class: Fee::FixedFeeType do
      sequence(:description) { |n| "AGFS, Fixed fee type, Contempt - #{n}" }
      code { random_safe_code }
      calculated true
      roles ['agfs']
    end

    factory :graduated_fee_type, class: Fee::GraduatedFeeType do
      sequence(:description) { |n| "LGFS, Fixed fee, Elected case not proceeded - #{n}" }
      code 'GTRL'
      calculated false
      roles ['lgfs']
    end

    factory :interim_fee_type, class: Fee::InterimFeeType do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code 'ITRS'
      calculated false
      roles ['lgfs']

      trait :disbursement do
        code 'IDISO'
        description 'Disbursement only'
      end

      trait :warrant do
        code 'IWARR'
        description 'Warrant'
      end

      trait :effective_pcmh do
        code 'IPCMH'
        description 'Effective PCMH'
      end

      trait :trial_start do
        code 'ITST'
        description 'Trial start'
      end

      trait :retrial_start do
        code 'IRST'
        description 'Retrial start'
      end

      trait :retrial_new_solicitor do
        code 'IRNS'
        description 'Retrial New solicitor'
      end
    end

    factory :transfer_fee_type, class: Fee::TransferFeeType do
      calculated false
      code 'TRANS'
      description 'Transfer'
      roles [ 'lgfs' ]
    end

    factory :warrant_fee_type, class: Fee::WarrantFeeType do
      description  'Warrant Fee'
      code 'XWAR'
      calculated false
      roles [ 'lgfs' ]
    end

    factory :child_fee_type, class: Fee::FixedFeeType do
      description "Child"
      roles [ 'lgfs' ]

      trait :asbo do
        description "Vary /discharge an ASBO s1c Crime and Disorder Act 1998"
      end

      trait :s155 do
        description "Alteration of Crown Court sentence s155 Powers of Criminal Courts (Sentencing Act 2000)"
      end

      trait :s74 do
        description "Assistance by defendant: review of sentence s74 Serious Organised Crime and Police Act 2005"
      end

      after(:build) do |fee_type|
        unless fee_type.parent
          parent = Fee::FixedFeeType.where(description: 'Hearing subsequent to sentence').first
          parent = FactoryGirl.build(:fixed_fee_type, :hsts, roles: ['lgfs']) if parent.nil?
          fee_type.parent = parent
        end
      end
    end
  end
end

def random_safe_code
  # NOTE: use ZXX (zed plus 2 random chars) to ensure we never have a code that will cause inappropriate validations
  'Z' << ('A'..'Z').to_a.sample(2).join
end
