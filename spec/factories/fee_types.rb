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
  factory :basic_fee_type, class: 'Fee::BasicFeeType' do
    sequence(:description) { |n| "AGFS, Basic fee type, basic fee -#{n}" }
    code { random_safe_code }
    calculated { true }
    roles { %w[agfs agfs_scheme_9] }
    quantity_is_decimal { false }
    unique_code { generate_unique_code }

    trait :lgfs do
      roles { ['lgfs'] }
    end

    trait :both_fee_schemes do
      roles { %w[lgfs agfs] }
    end

    trait :agfs_scheme_9 do
      roles { %w[agfs agfs_scheme_9] }
    end

    trait :agfs_scheme_10 do
      roles { %w[agfs agfs_scheme_10] }
    end

    trait :agfs_scheme_12 do
      roles { %w[agfs agfs_scheme_12] }
    end

    trait :lgfs_agfs_scheme_12 do
      roles { %w[lgfs agfs agfs_scheme_12] }
    end

    trait :lgfs_agfs_scheme_14 do
      roles { %w[lgfs agfs agfs_scheme_14] }
    end

    trait :agfs_scheme_15 do
      roles { %w[agfs agfs_scheme_15] }
    end

    trait :agfs_all_schemes do
      roles { %w[agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12] }
    end

    trait :baf do
      description { 'Basic Fee' }
      code { 'BAF' }
      unique_code { 'BABAF' }
      agfs_all_schemes
    end

    trait :dat do
      description { 'Daily Attendance Fee (2+)' }
      code { 'DAT' }
      unique_code { 'BADAT' }
      agfs_scheme_10
    end

    trait :daf do
      description { 'Daily Attendance Fee (3 to 40)' }
      code { 'DAF' }
      unique_code { 'BADAF' }
      agfs_scheme_9
    end

    trait :dah do
      description { 'Daily Attendance Fee (41 to 50)' }
      code { 'DAH' }
      unique_code { 'BADAH' }
      agfs_scheme_9
    end

    trait :daj do
      description { 'Daily Attendance Fee (50+)' }
      code { 'DAJ' }
      unique_code { 'BADAJ' }
      agfs_scheme_9
    end

    trait :pcm do
      description { 'Plea and Case Management Hearing' }
      code { 'PCM' }
      unique_code { 'BAPCM' }
      agfs_all_schemes
    end

    trait :ppe do
      description { 'Pages of prosecution evidence' }
      code { 'PPE' }
      calculated { false }
      unique_code { 'BAPPE' }
      agfs_scheme_9
    end

    trait :cav do
      description { 'Conferences and views' }
      code { 'CAV' }
      unique_code { 'BACAV' }
      quantity_is_decimal { true }
    end

    trait :npw do
      description { 'Number of prosecution witnesses' }
      code { 'NPW' }
      calculated { false }
      unique_code { 'BANPW' }
    end

    trait :noc do
      description { 'Number of cases uplift' }
      code { 'NOC' }
      unique_code { 'BANOC' }
      agfs_all_schemes
    end

    trait :ndr do
      description { 'Number of defendants uplift' }
      code { 'NDR' }
      unique_code { 'BANDR' }
      agfs_all_schemes
    end

    trait :hsts do
      description { 'Hearing subsequent to sentence' }
      roles { ['lgfs'] }
    end

    trait :babaf do
      baf
    end

    trait :badat do
      daf
    end

    trait :badaf do
      daf
    end

    trait :badah do
      dah
    end

    trait :badaj do
      daj
    end

    trait :basaf do
      description { 'Standard appearance fee' }
      code { 'SAF' }
      unique_code { 'BASAF' }
      agfs_all_schemes
    end

    trait :bapcm do
      pcm
    end

    trait :bacav do
      cav
    end

    trait :bandr do
      ndr
    end

    trait :banoc do
      noc
    end

    trait :bappe do
      ppe
    end

    trait :banpw do
      npw
    end

    factory :misc_fee_type, class: 'Fee::MiscFeeType' do
      sequence(:description) { |n| "AGFS, Misc fee type, Noting brief - #{n}" }
      code { random_safe_code }
      calculated { true }
      roles { ['agfs'] }

      trait :lgfs do
        sequence(:description) { |n| "LGFS, Misc fee type, Special preparation fee - #{n}" }
        calculated { false }
        roles { ['lgfs'] }
      end

      trait :spf do
        description { 'Special preparation fee' }
        code { 'SPF' }
        quantity_is_decimal { true }
      end

      trait :mispf do
        description { 'Special preparation fee' }
        code { 'SPF' }
        unique_code { 'MISPF' }
        calculated { true }
        quantity_is_decimal { true }
        roles { %w[agfs agfs_scheme_9 agfs_scheme_10 lgfs] }
      end

      trait :misaf do
        description { 'Standard appearance fee' }
        code { 'SAF' }
        unique_code { 'MISAF' }
        agfs_all_schemes
      end

      trait :misau do
        description { 'Standard appearance fee uplift' }
        code { 'SAU' }
        unique_code { 'MISAU' }
        agfs_all_schemes
      end

      trait :minbr do
        description { 'Noting brief fee' }
        code { 'NBR' }
        unique_code { 'MINBR' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_all_schemes
      end

      trait :miaph do
        description { 'Abuse of process hearings (half day)' }
        code { 'APH' }
        unique_code { 'MIAPH' }
        calculated { true }
        quantity_is_decimal { false }
      end

      trait :miahu do
        description { 'Abuse of process hearings (half day uplift)' }
        code { 'AHU' }
        unique_code { 'MIAHU' }
        calculated { true }
        quantity_is_decimal { false }
      end

      trait :midtw do
        description { 'Confiscation hearings (whole day)' }
        code { 'DTW' }
        unique_code { 'MIDTW' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_all_schemes
      end

      trait :midwu do
        description { 'Confiscation hearings (whole day uplift)' }
        code { 'DWU' }
        unique_code { 'MIDWU' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_all_schemes
      end

      trait :midth do
        description { 'Confiscation hearings (half day)' }
        code { 'DTH' }
        unique_code { 'MIDTH' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_all_schemes
      end

      trait :midhu do
        description { 'Confiscation hearings (half day uplift)' }
        code { 'DHU' }
        unique_code { 'MIDHU' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_all_schemes
      end

      trait :miphc do
        description { 'Paper heavy case' }
        code { 'PHC' }
        unique_code { 'MIPHC' }
        calculated { true }
        quantity_is_decimal { true }
        agfs_scheme_12
      end

      trait :miumu do
        description { 'Unused materials (up to 3 hours)' }
        code { 'UMU' }
        unique_code { 'MIUMU' }
        calculated { true }
        quantity_is_decimal { true }
        lgfs_agfs_scheme_12
      end

      trait :miumo do
        description { 'Unused materials (over 3 hours)' }
        code { 'UMO' }
        unique_code { 'MIUMO' }
        calculated { true }
        quantity_is_decimal { true }
        lgfs_agfs_scheme_12
      end

      trait :miste do
        description { 'Section 28 hearing' }
        code { 'STE' }
        unique_code { 'MISTE' }
        calculated { true }
        quantity_is_decimal { true }
        lgfs_agfs_scheme_14
      end

      trait :miupl do
        lgfs
        description { 'Defendant uplift' }
        code { 'XUPL' }
        unique_code { 'MIUPL' }
        quantity_is_decimal { true }
      end

      trait :mievi do
        lgfs
        description { 'Evidence provision fee' }
        code { 'XEVI' }
        unique_code { 'MIEVI' }
        quantity_is_decimal { false }
      end

      trait :midse do
        description { 'Deferred sentence hearings' }
        code { 'DSE' }
        unique_code { 'MIDSE' }
        calculated { true }
        quantity_is_decimal { false }
      end

      trait :midsu do
        description { 'Deferred sentence hearings uplift' }
        code { 'DSU' }
        unique_code { 'MIDSU' }
        calculated { true }
        quantity_is_decimal { false }
      end

      trait :miapf do
        description { 'Additional preparation fee' }
        code { 'APF' }
        unique_code { 'MIAPF' }
        calculated { true }
        quantity_is_decimal { false }
        agfs_scheme_15
      end
    end

    factory :fixed_fee_type, class: 'Fee::FixedFeeType' do
      sequence(:description) { |n| "AGFS, Fixed fee type, Contempt - #{n}" }
      code { random_safe_code }
      calculated { true }
      roles { ['agfs'] }

      trait :fxcbr do
        description { 'Breach of a crown court order' }
        code { 'CBR' }
        unique_code { 'FXCBR' }
        roles { %w[agfs lgfs] }
        quantity_is_decimal { false }
      end

      trait :fxndr do
        description { 'Number of defendants uplifts' }
        code { 'NDR' }
        unique_code { 'FXNDR' }
        roles { %w[agfs lgfs] }
        quantity_is_decimal { false }
      end

      trait :fxcbu do
        description { 'Breach of a crown court order uplift' }
        code { 'CBU' }
        unique_code { 'FXCBU' }
        quantity_is_decimal { false }
      end

      trait :fxnoc do
        description { 'Number of cases uplift' }
        code { 'NOC' }
        unique_code { 'FXNOC' }
        quantity_is_decimal { false }
      end

      trait :fxndr do
        description { 'Number of defendants uplift' }
        code { 'NDR' }
        unique_code { 'FXNDR' }
        quantity_is_decimal { false }
      end

      trait :fxacv do
        description { 'Appeals to the crown court against conviction' }
        code { 'ACV' }
        unique_code { 'FXACV' }
        quantity_is_decimal { false }
      end

      trait :fxacu do
        description { 'Appeals to the crown court against conviction uplift' }
        code { 'ACU' }
        unique_code { 'FXACU' }
        quantity_is_decimal { false }
      end

      trait :fxsaf do
        description { 'Standard appearance fee' }
        code { 'SAF' }
        unique_code { 'FXSAF' }
        quantity_is_decimal { false }
      end

      trait :fxase do
        description { 'Appeal against sentence' }
        code { 'ASE' }
        unique_code { 'FXASE' }
        quantity_is_decimal { false }
      end

      trait :fxenp do
        description { 'Elected case not proceeded' }
        code { 'ENP' }
        unique_code { 'FXENP' }
        quantity_is_decimal { false }
        roles { %w[agfs agfs_scheme_9 agfs_scheme_10 lgfs] }
      end
    end

    factory :graduated_fee_type, class: 'Fee::GraduatedFeeType' do
      sequence(:description) { |n| "LGFS, Fixed fee, Elected case not proceeded - #{n}" }
      code { 'GTRL' }
      calculated { false }
      roles { ['lgfs'] }

      trait :grtrl do
        description { 'Trial' }
        unique_code { 'GRTRL' }
        code { 'GTRL' }
        calculated { false }
        quantity_is_decimal { false }
      end
    end

    factory :interim_fee_type, class: 'Fee::InterimFeeType' do
      sequence(:description) { |n| "#{Faker::Lorem.word}-#{n}" }
      code { 'ITRS' }
      calculated { false }
      roles { ['lgfs'] }

      trait :disbursement_only do
        code { 'IDISO' }
        unique_code { 'INDIS' }
        description { 'Disbursement only' }
      end

      trait :warrant do
        code { 'IWARR' }
        unique_code { 'INWAR' }
        description { 'Warrant' }
      end

      trait :effective_pcmh do
        code { 'IPCMH' }
        unique_code { 'INPCM' }
        description { 'Effective PCMH' }
      end

      trait :trial_start do
        code { 'ITST' }
        unique_code { 'INTDT' }
        description { 'Trial start' }
      end

      trait :retrial_start do
        code { 'IRST' }
        unique_code { 'INRST' }
        description { 'Retrial start' }
      end

      trait :retrial_new_solicitor do
        code { 'IRNS' }
        unique_code { 'INRNS' }
        description { 'Retrial New solicitor' }
      end
    end

    factory :transfer_fee_type, class: 'Fee::TransferFeeType' do
      calculated { false }
      code { 'TRANS' }
      unique_code { 'TRANS' }
      description { 'Transfer' }
      roles { ['lgfs'] }
    end

    factory :warrant_fee_type, class: 'Fee::WarrantFeeType' do
      description { 'Warrant Fee' }
      code { 'XWAR' }
      calculated { false }
      roles { ['lgfs'] }

      trait :warr do
        unique_code { 'WARR' }
      end
    end

    factory :hardship_fee_type, class: 'Fee::HardshipFeeType' do
      description { 'Hardship Fee' }
      code { 'HARDSHIP' }
      calculated { false }
      roles { ['lgfs'] }
    end

    factory :child_fee_type, class: 'Fee::FixedFeeType' do
      description { 'Child' }
      roles { ['lgfs'] }

      trait :asbo do
        description { 'Vary /discharge an ASBO s1c Crime and Disorder Act 1998' }
      end

      trait :s155 do
        description { 'Alteration of Crown Court sentence s155 Powers of Criminal Courts (Sentencing Act 2000)' }
      end

      trait :s74 do
        description { 'Assistance by defendant: review of sentence s74 Serious Organised Crime and Police Act 2005' }
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
  code = ('A'..'Z').to_a.sample(5).join while Fee::BaseFeeType.where(unique_code: code).any?
  code
end
