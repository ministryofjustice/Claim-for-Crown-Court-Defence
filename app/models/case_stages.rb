# frozen_string_literal: true

# Stage id, Stage Description, Graduated-fee/scenario/case-type
# 1 Pre PTPH  Discontinuance
# 2 After PTPH before trial   cracked trial
# 3 Trial started but not concluded   trial
# 4 GP not yet sentenced  guilty plea
# 5 Trial ended not yet sentenced trial
# 6 Retrial listed but not started  cracked trial
# 7 Retrial started but not concluded   retrial
# 8 Retrial ended not yet sentenced retrial
#
class CaseStage
  attr_accessor :stage_id, :stage_description, :case_type

  delegate_missing_to :case_type

  def initialize(stage_id, stage_description, case_type)
    @stage_id = stage_id
    @stage_description = stage_description
    @case_type = case_type
  end

  # overide case type name
  def name
    stage_description
  end
end

class CaseStages
  class << self
    def all
      CASE_STAGES
    end

    private

    def case_stage(stage_id, stage_description, fee_type_code)
      CaseStage.new(stage_id, stage_description, CaseType.find_by(fee_type_code: fee_type_code))
    end
  end

  CASE_STAGES = [
    case_stage(1, 'Pre-PTPH', 'GRDIS'),
    case_stage(2, 'After PTPH before trial', 'GRRAK'),
    case_stage(3, 'Trial started but not concluded or ended not yet sentenced', 'GRTRL'),
    case_stage(4, 'Guilty plea not yet sentenced', 'GRGLT'),
    case_stage(6, 'Retrial listed but not started', 'GRCBR'),
    case_stage(7, 'Retrial started but not concluded or ended not yet sentenced', 'GRRTR')
  ].freeze
end
