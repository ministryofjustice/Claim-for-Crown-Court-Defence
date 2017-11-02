require_relative 'lgfs_scheme_claim_generator'

module DemoData
  class AdvocateClaimGenerator < BaseClaimGenerator

    def generate_claim(advocate)
      claim = Claim::AdvocateClaim.new(
        creator: advocate,
        external_user: advocate,
        advocate_category: Settings.advocate_categories.sample,
        court: Court.all.sample,
        case_type: CaseType.agfs.sample,
        case_number: random_case_number,
        providers_ref: ((rand(1..4) % 4).zero? ? nil : SecureRandom.uuid[3..15].upcase),
        offence: Offence.all.sample,
        apply_vat: ((rand(1..4) % 4).zero? ? false : true),
        state: "draft",
        cms_number: "CMS-2015-195-1",
        evidence_checklist_ids: [],
        source: "web",
        vat_amount: 0.0,
        additional_information: generate_additional_info
      )
      claim.save!
      puts "Added claim #{claim.id} #{claim.case_type.name} for advocate #{advocate.name}"
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
      FactoryBot.create(:certification,  claim: claim, certified_by: claim.external_user.name, certification_type: CertificationType.all.sample)
      claim.save!
    end

  end
end
