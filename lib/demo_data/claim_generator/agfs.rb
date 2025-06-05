module DemoData
  class ClaimGenerator
    class AGFS < ClaimGenerator
      def generate_claim(klass, external_user)
        claim = klass.new(
          creator: external_user,
          external_user: external_user,
          advocate_category: advocate_category,
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

        puts "Added #{klass.to_s.demodulize} #{claim.id} #{claim.case_type.name} for advocate #{external_user.name}"
        add_defendants(claim)
        add_documents(claim)
        add_claim_detail(claim)
        claim.save

        add_fees_expenses_and_disbursements(claim)
        # load all the fees and expenses that have been created
        claim.reload
        # save in order to update fee and expense totals
        claim.save
        claim
      end

      private

      def add_certification(claim)
        FactoryBot.create(:certification, claim: claim, certified_by: claim.creator.name, certification_type: CertificationType.all.sample)
        claim.save!
      end

      def advocate_category
        ['QC', 'Leading junior'].sample
      end

      def add_fees_expenses_and_disbursements(claim)
        add_fees(claim)
        add_expenses(claim)
      end
    end
  end
end
