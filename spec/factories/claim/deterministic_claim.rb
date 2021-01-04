FactoryBot.define do
  factory :deterministic_claim, class: 'Claim::AdvocateClaim' do
    before(:create) do
      Timecop.freeze(Time.new(2016, 3, 10, 11, 44, 55).utc)
    end

    after(:create) do |claim, _evaluator|
      create_list(:message, 1, :with_attachment, body: 'This is the message body.', claim: claim, sender: claim.external_user.user)
      Timecop.return
    end

    trait :submitted do
      after(:create) { |c| frozen_time { c.submit! } }
    end

    trait :redetermination do
      after(:create) do |c|
        frozen_time do
          c.submit!
          c.allocate!
          c.assessment.update(fees: 24.2, expenses: 8.5)
          c.authorise!
          c.redetermine!
        end
      end
    end

    # ---------------------------------------

    transient do
      rep_order_date { Date.new(2016, 1, 10) }
    end

    # ---------------------------------------

    uuid { SecureRandom.uuid }
    providers_ref { 'reference-123' }
    advocate_category { 'QC' }
    cms_number { 'CMS-12345' }
    additional_information { 'This is some important additional information.' }
    evidence_checklist_ids { [1,3] }
    apply_vat { true }

    case_number { 'T20161234' }
    transfer_case_number { 'A20161234' }

    court do
      build(:court, code: 'ABC', name: 'Acme Court', court_type: 'crown')
    end
    transfer_court do
      build(:court, code: 'ZZZ', name: 'Northern Court', court_type: 'crown')
    end

    external_user do
      build(:external_user, supplier_number: 'XY666', user: build(:user, first_name: 'John', last_name: 'Smith', email: 'john.smith@example.com'))
    end

    creator do
      external_user
    end

    offence do
      build(:offence, description: 'Miscellaneous/other', offence_class: build_or_reuse_offence_class)
    end

    case_type do
      build(:case_type, :fixed_fee)
    end

    defendants do |env|
      build_list(
        :defendant, 1, first_name: 'Kaia', last_name: 'Casper', date_of_birth: Date.new(1995, 6, 20),
                       representation_orders: build_list(:representation_order, 1, maat_reference: '4567890',
                                                                                   representation_order_date: env.rep_order_date)
      )
    end

    fees do
      build_list(:basic_fee, 1, :ppe_fee)
    end

    expenses do |env|
      build_list(:expense, 1, :car_travel, location: 'Brighton', date: env.rep_order_date)
    end

    documents do
      build_list(:document, 1, :verified)
    end

    redeterminations do
      build_list(:redetermination, 1, fees: 25.0, expenses: 9.2, disbursements: 0)
    end
  end
end

# ---------------------------------------

def build_or_reuse_offence_class
  class_letter = 'C'
  description = 'Lesser offences involving violence or damage and less serious drug offences'

  if (oc = OffenceClass.find_by(class_letter: class_letter))
    oc.update_column(:description, description)
  else
    build(:offence_class, class_letter: class_letter, description: description)
  end
end
