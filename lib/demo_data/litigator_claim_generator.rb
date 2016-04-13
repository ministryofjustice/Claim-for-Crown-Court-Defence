require_relative 'base_claim_generator'
require_relative 'disbursement_generator'

module DemoData
  class LitigatorClaimGenerator < BaseClaimGenerator

    def generate_claim(litigator)
      claim = Claim::LitigatorClaim.new(
        creator: litigator,
        external_user: litigator,
        advocate_category: nil,
        court: Court.all.sample,
        case_type: CaseType.lgfs.sample,
        case_number: ('A'..'Z').to_a.sample +  rand(10000000..99999999).to_s,
        offence: Offence.miscellaneous.sample,
        apply_vat: (rand(1..4) % 4 == 0 ? false : true),
        state: "draft",
        cms_number: "CMS-2015-195-1",
        evidence_checklist_ids: [],
        source: "web",
        vat_amount: 0.0,
        additional_information: generate_additional_info
        
      )
      claim.case_concluded_at = generate_case_concluded_at(claim)
      claim.save!
      puts "Added claim #{claim.id} #{claim.case_type.name} for litigator #{litigator.name}"
      add_defendants(claim)
      add_documents(claim)
      add_claim_detail(claim)
      claim.save
      add_fees(claim)
      add_expenses(claim)
      add_disbursements(claim)
      claim.reload              # load all the fees, expenses and disbursements that have been created
      claim.save                # save in order to update fee, expense and disbursement totals
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

    def add_fees(claim)
      add_fixed_fees(claim) if claim.case_type.is_fixed_fee?
      add_misc_fees(claim)
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
