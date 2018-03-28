# == Schema Information
#
# Table name: fee_types
#
#  id                  :integer          not null, primary key
#  description         :string
#  code                :string
#  created_at          :datetime
#  updated_at          :datetime
#  max_amount          :decimal(, )
#  calculated          :boolean          default(TRUE)
#  type                :string
#  roles               :string
#  parent_id           :integer
#  quantity_is_decimal :boolean          default(FALSE)
#  unique_code         :string
#

FactoryBot.define do
  factory :basic_fee_type, class: Fee::BasicFeeType do
    sequence(:description) { |n| "AGFS, Basic fee type, basic fee -#{n}" }
    code { random_safe_code }
    calculated true
    roles ['agfs']
    quantity_is_decimal false
    unique_code { generate_unique_code }

    trait :agfs_scheme_9 do
      roles %w[agfs agfs_scheme_9]
    end

    trait :agfs_scheme_10 do
      roles %w[agfs agfs_scheme_10]
    end

    trait :ppe do
      description 'Pages of prosecution evidence'
      code 'PPE'
      calculated false
      unique_code 'BAPPE'
    end

    trait :npw do
      description 'Number of prosecution witnesses'
      code 'NPW'
      calculated false
      unique_code 'BANPW'
    end

    trait :noc do
      description 'Number of cases uplift'
      code 'NOC'
      unique_code 'BANOC'
    end

    trait :ndr do
      description 'Number of cases uplift'
      code 'NOC'
      unique_code 'BANDR'
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

      trait :spf do
        description 'Special preparation fee'
        code 'SPF'
        quantity_is_decimal true
      end

      trait :mispf do
        description 'Special preparation fee'
        code 'SPF'
        unique_code 'MISPF'
        calculated true
        quantity_is_decimal true
      end

      trait :miaph do
        description 'Abuse of process hearings (half day)'
        code 'APH'
        unique_code 'MIAPH'
        calculated true
        quantity_is_decimal false
      end

      trait :miahu do
        description 'Abuse of process hearings (half day uplift)'
        code 'AHU'
        unique_code 'MIAHU'
        calculated true
        quantity_is_decimal false
      end

      trait :midtw do
        description 'Confiscation hearings (whole day)'
        code 'DTW'
        unique_code 'MIDTW'
        calculated true
        quantity_is_decimal false
      end

      trait :midwu do
        description 'Confiscation hearings (whole day uplift)'
        code 'DWU'
        unique_code 'MIDWU'
        calculated true
        quantity_is_decimal false
      end

      trait :miupl do
        lgfs
        description 'Case uplift'
        code 'XUPL'
        unique_code 'MIUPL'
        quantity_is_decimal true
      end

      trait :mievi do
        lgfs
        description 'Evidence provision fee'
        code 'XEVI'
        unique_code 'MIEVI'
        quantity_is_decimal false
      end
    end

    factory :fixed_fee_type, class: Fee::FixedFeeType do
      sequence(:description) { |n| "AGFS, Fixed fee type, Contempt - #{n}" }
      code { random_safe_code }
      calculated true
      roles ['agfs']

      trait :fxcbr do
        description 'Breach of a crown court order'
        code 'CBR'
        unique_code 'FXCBR'
        roles ['agfs','lgfs']
        quantity_is_decimal false
      end

      trait :fxcbu do
        description 'Breach of a crown court order uplift'
        code 'CBU'
        unique_code 'FXCBU'
        roles ['agfs']
        quantity_is_decimal false
      end

      trait :fxnoc do
        description 'Number of cases uplift'
        code 'NOC'
        unique_code 'FXNOC'
        quantity_is_decimal false
      end

      trait :fxndr do
        description 'Number of defendants uplift'
        code 'NDR'
        unique_code 'FXNDR'
        quantity_is_decimal false
      end

      trait :fxacv do
        description 'Appeals to the crown court against conviction'
        code 'ACV'
        unique_code 'FXACV'
        quantity_is_decimal false
      end
    end

    factory :graduated_fee_type, class: Fee::GraduatedFeeType do
      sequence(:description) { |n| "LGFS, Fixed fee, Elected case not proceeded - #{n}" }
      code 'GTRL'
      calculated false
      roles ['lgfs']

      trait :grtrl do
        description 'Trial'
        unique_code 'GRTRL'
        code 'GTRL'
        calculated false
        quantity_is_decimal false
      end
    end

    factory :interim_fee_type, class: Fee::InterimFeeType do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code 'ITRS'
      calculated false
      roles ['lgfs']

      trait :disbursement_only do
        code 'IDISO'
        unique_code 'INDIS'
        description 'Disbursement only'
      end

      trait :warrant do
        code 'IWARR'
        unique_code 'INWAR'
        description 'Warrant'
      end

      trait :effective_pcmh do
        code 'IPCMH'
        unique_code 'INPCM'
        description 'Effective PCMH'
      end

      trait :trial_start do
        code 'ITST'
        unique_code 'INTDT'
        description 'Trial start'
      end

      trait :retrial_start do
        code 'IRST'
        unique_code 'INRST'
        description 'Retrial start'
      end

      trait :retrial_new_solicitor do
        code 'IRNS'
        unique_code 'INRNS'
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
      description 'Warrant Fee'
      code 'XWAR'
      calculated false
      roles [ 'lgfs' ]

      trait :warr do
        unique_code 'WARR'
      end
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
          parent = FactoryBot.build(:fixed_fee_type, :hsts, roles: ['lgfs']) if parent.nil?
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

def generate_unique_code
  code = ('A'..'Z').to_a.sample(5).join
  while Fee::BaseFeeType.where(unique_code: code).any?
    code = ('A'..'Z').to_a.sample(5).join
  end
  code
end
