# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :decimal(, )
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#  sub_type_id           :integer
#  case_numbers          :string
#  date                  :date
#

FactoryBot.define do
  factory :fixed_fee, class: Fee::FixedFee do
    claim { build(:advocate_claim, :with_fixed_fee_case) }
    fee_type { build :fixed_fee_type }
    quantity { 1 }
    rate { 25 }

    trait :lgfs do
      claim { build(:litigator_claim, :with_fixed_fee_case) }
      fee_type { build :fixed_fee_type, :lgfs }
      quantity { 1 }
      rate { 25 }
      date { 3.days.ago }
    end

    trait :fxnoc_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXNOC') || build(:fixed_fee_type, :fxnoc) }
    end

    trait :fxndr_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXNDR') || build(:fixed_fee_type, :fxndr) }
    end

    trait :fxcbr_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXCBR') || build(:fixed_fee_type, :fxcbr) }
    end

    trait :fxcbu_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXCBU') || build(:fixed_fee_type, :fxcbu) }
    end

    trait :fxacv_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXACV') || build(:fixed_fee_type, :fxacv) }
    end

    trait :fxacu_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXACU') || build(:fixed_fee_type, :fxacu) }
    end

    trait :fxsaf_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXSAF') || build(:fixed_fee_type, :fxsaf) }
    end

    trait :fxenp_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXENP') || build(:fixed_fee_type, :fxenp) }
    end

    trait :fxase_fee do
      fee_type { Fee::FixedFeeType.find_by(unique_code: 'FXASE') || build(:fixed_fee_type, :fxase) }
    end
  end

  factory :misc_fee, class: Fee::MiscFee do
    claim
    fee_type { build :misc_fee_type }
    quantity { 1 }
    rate { 25 }

    trait :lgfs do
      fee_type { build :misc_fee_type, :lgfs }
      quantity { 0 }
      rate { 0 }
      amount { 25 }
    end

    trait :spf_fee do
      fee_type { build :misc_fee_type, :spf }
    end

    trait :mispf_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MISPF') || build(:misc_fee_type, :mispf) }
    end

    trait :misaf_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MISAF') || build(:misc_fee_type, :misaf) }
    end

    trait :misau_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MISAU') || build(:misc_fee_type, :misau) }
    end

    trait :miaph_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MIAPH') || build(:misc_fee_type, :miaph) }
    end

    trait :miahu_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MIAHU') || build(:misc_fee_type, :miahu) }
    end

    trait :minbr_fee do
      fee_type { Fee::MiscFeeType.find_by(unique_code: 'MINBR') || build(:misc_fee_type, :minbr) }
    end
  end

  factory :warrant_fee, class: Fee::WarrantFee do
    claim
    fee_type { build :warrant_fee_type }
    warrant_issued_date { Fee::WarrantFeeValidator::MINIMUM_PERIOD_SINCE_ISSUED.ago }
    amount { 25.01 }

    trait :warrant_executed do
      warrant_exectuted_date { warrant_issued_date + 5.days }
    end

    trait :warr_fee do
      fee_type { Fee::WarrantFeeType.find_by(unique_code: 'WARR') || build(:warrant_fee_type, :warr) }
    end

    after(:build) do |fee|
      fee.fee_type = Fee::WarrantFeeType.instance || build(:warrant_fee_type)
    end
  end

  factory :interim_fee, class: Fee::InterimFee do
    claim { build :interim_claim }
    fee_type { build :interim_fee_type }
    quantity { 2 }
    amount { 245.56 }
    uuid { SecureRandom.uuid }
    rate { nil }

    trait :disbursement do
      claim { build :interim_claim, disbursements: build_list(:disbursement, 1) }
      fee_type { build :interim_fee_type, :disbursement_only }
      amount { nil }
      quantity { nil }
    end

    trait :warrant do
      fee_type { build :interim_fee_type, :warrant }
      quantity { nil }
      amount { 25.02 }
      warrant_issued_date { 5.days.ago }
    end

    trait :effective_pcmh do
      fee_type { build :interim_fee_type, :effective_pcmh }
      quantity { nil }
    end

    trait :trial_start do
      fee_type { build :interim_fee_type, :trial_start }
      quantity { 1 }
    end

    trait :retrial_start do
      fee_type { build :interim_fee_type, :retrial_start }
      quantity { 1 }
    end

    trait :retrial_new_solicitor do
      fee_type { build :interim_fee_type, :retrial_new_solicitor }
      quantity { nil }
    end
  end

  factory :basic_fee, class: Fee::BasicFee do
    claim
    fee_type { build :basic_fee_type }
    quantity { 1 }
    rate { 25 }

    trait :baf_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BABAF') || build(:basic_fee_type, :baf) }
    end

    trait :daf_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BADAF') || build(:basic_fee_type, :daf) }
    end

    trait :dah_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BADAH') || build(:basic_fee_type, :dah) }
    end

    trait :daj_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BADAJ') || build(:basic_fee_type, :daj) }
    end

    trait :dat_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BADAT') || build(:basic_fee_type, :dat) }
    end

    trait :saf_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BASAF') || build(:basic_fee_type, :basaf) }
    end

    trait :pcm_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BAPCM') || build(:basic_fee_type, :pcm) }
    end

    trait :cav_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BACAV') || build(:basic_fee_type, :cav) }
    end

    trait :ppe_fee do
      rate { 0 }
      amount { 25 }
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BAPPE') || build(:basic_fee_type, :ppe) }
    end

    trait :ndr_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BANDR') || build(:basic_fee_type, :ndr) }
    end

    trait :noc_fee do
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BANOC') || build(:basic_fee_type, :noc) }
    end

    trait :npw_fee do
      rate { 0 }
      amount { 25 }
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BANPW') || build(:basic_fee_type, :npw) }
    end

    trait :npw_fee do
      rate { 0 }
      amount { 25 }
      fee_type { Fee::BasicFeeType.find_by(unique_code: 'BANPW') || build(:basic_fee_type, :npw) }
    end

    # trait "aliases"
    trait :babaf_fee do baf_fee end
    trait :badaf_fee do daf_fee end
    trait :badah_fee do dah_fee end
    trait :badaj_fee do daj_fee end
    trait :badat_fee do dat_fee end
    trait :basaf_fee do saf_fee end
    trait :bapcm_fee do pcm_fee end
    trait :bacav_fee do cav_fee end
    trait :bandr_fee do ndr_fee end
    trait :banoc_fee do noc_fee end
    trait :bappe_fee do ppe_fee end
    trait :banpw_fee do npw_fee end
  end

  factory :transfer_fee, class: Fee::TransferFee do
    claim { build :transfer_claim }
    fee_type { build :transfer_fee_type }
    quantity { 0 }
    rate { 0 }
    amount { 25 }
  end

  factory :graduated_fee, class: Fee::GraduatedFee do
    claim
    fee_type { build :graduated_fee_type }
    quantity { 1 }
    amount { 25 }
    rate { 0 }
    date { 3.days.ago }

    trait :guilty_plea_fee do
      fee_type { build(:graduated_fee_type, description: 'Guilty plea', code: 'GGLTY') }
    end

    trait :trial_fee do
      fee_type { build(:graduated_fee_type, :grtrl) }
    end
  end

  trait :with_date_attended do
    after(:build) do |fee|
      fee.dates_attended << build(:date_attended, attended_item: fee)
    end
  end

  trait :random_values do
    quantity { rand(1..15) }
    rate { rand(50..80) }
    amount   { rand(100..999).round(0) }
  end

  trait :all_zero do
    quantity { 0 }
    rate { 0 }
  end

  trait :from_api do
    claim         { FactoryBot.create :claim, source: 'api' }
  end
end
