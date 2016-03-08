require_relative 'base_claim_generator'

module DemoData
  class LitigatorClaimGenerator < BaseClaimGenerator

    def generate_claim(litigator)
      claim = Claim::LitigatorClaim.new(
        creator: litigator,
        external_user: nil,
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
      claim.save!
      puts "Added claim #{claim.id} #{claim.case_type.name} for litigator #{litigator.name}"
      add_defendants(claim)
      add_documents(claim)
      add_claim_detail(claim)
      claim.save
      add_fees(claim)
      add_expenses(claim)
      claim.reload              # load all the fees and expenses that have been created
      claim.save                # save in order to update fee and expense totals
      claim
    end

  private

    def add_certification(claim)
      FactoryGirl.create(:certification, claim: claim, certified_by: claim.creator.name, certification_type: CertificationType.all.sample)
      claim.save!
    end

  end
end
