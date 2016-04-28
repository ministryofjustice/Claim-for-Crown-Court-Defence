module DemoData
  class TransferDetailGenerator

    def initialize(claim)
      @claim = claim
    end

    def generate!
      @claim.litigator_type = random_litigator_type
      @claim.elected_case = random_elected_case
      @claim.transfer_stage_id = valid_transfer_stage_id
      @claim.case_conclusion_id = valid_case_conclusion_id
      @claim.save!
      @claim.transfer_detail.save!
    end

    private

    def random_litigator_type
      %w(new original).sample
    end

    def random_elected_case
      [ true, false ].sample
    end

    def valid_transfer_stage_id
      Claim::TransferBrainDataItemCollection.instance.valid_transfer_stage_ids(@claim.litigator_type, @claim.elected_case).sample
    end

    def valid_case_conclusion_id
      Claim::TransferBrainDataItemCollection.instance.valid_case_conclusion_ids(@claim.litigator_type, @claim.elected_case, @claim.transfer_stage_id).sample
    end
  end
end