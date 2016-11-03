require_relative 'base_claim_generator'
require_relative 'disbursement_generator'

module DemoData
  # For claims: litigator, interim, transfer...
  class LgfsSchemeClaimGenerator < BaseClaimGenerator

    def generate_claim(klass, litigator)
      claim = klass.new(
          creator: litigator,
          external_user: litigator,
          advocate_category: nil,
          court: Court.all.sample,
          case_number: random_case_number,
          providers_ref: (rand(1..4) % 4 == 0 ? nil : SecureRandom.uuid[3..15].upcase),
          offence: Offence.miscellaneous.sample,
          apply_vat: (rand(1..4) % 4 == 0 ? false : true),
          state: "draft",
          cms_number: "CMS-2015-195-1",
          evidence_checklist_ids: [],
          source: "web",
          vat_amount: 0.0,
          additional_information: generate_additional_info,
          supplier_number: litigator.provider.lgfs_supplier_numbers.sample.supplier_number
      )

      claim.case_type = claim.eligible_case_types.sample
      claim.case_concluded_at = generate_case_concluded_at(claim)
      claim.save!

      puts "Added #{klass.to_s.demodulize} #{claim.id} #{claim.case_type.name} for litigator #{litigator.name}"
      add_defendants(claim)
      add_documents(claim)
      add_claim_detail(claim)
      claim.save

      add_fees_expenses_and_disbursements(claim)
      claim.reload  # load all the fees, expenses and disbursements that have been created
      claim.save    # save in order to update fee, expense and disbursement totals
      claim
    end

    private

    def add_certification(claim)
      FactoryGirl.create(:certification, claim: claim, certified_by: claim.creator.name, certification_type: CertificationType.all.sample)
      claim.save!
    end

    def add_disbursements(claim)
      DisbursementGenerator.new(claim).generate!
    end

    def latest_of(*dates)
      latest = Date.new(1970, 1, 1)
      dates.each do |date|
        latest = date unless (date.nil? || date < latest)
      end
      latest + 1
    end

    def generate_case_concluded_at(claim)
      latest_of(
          claim.trial_concluded_at,
          claim.retrial_concluded_at,
          claim.trial_fixed_notice_at,
          claim.trial_fixed_at,
          claim.trial_cracked_at,
          claim.trial_cracked_at_third,
          random_concluded_date)
    end

    def random_concluded_date
      rand(1..10).days.ago
    end
  end
end
