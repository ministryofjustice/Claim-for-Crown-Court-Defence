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
  CASE_STAGES = [
    CaseStage.new(1, 'Pre-PTPH', CaseType.find_by(fee_type_code: 'GRDIS')),
    CaseStage.new(2, 'After PTPH before trial', CaseType.find_by(fee_type_code: 'GRRAK')),
    CaseStage.new(3, 'Trial started but not concluded or ended not yet sentenced', CaseType.find_by(fee_type_code: 'GRTRL')),
    CaseStage.new(4, 'Guilty plea not yet sentenced', CaseType.find_by(fee_type_code: 'GRGLT')),
    CaseStage.new(6, 'Retrial listed but not started', CaseType.find_by(fee_type_code: 'GRCBR')),
    CaseStage.new(7, 'Retrial started but not concluded or ended not yet sentenced', CaseType.find_by(fee_type_code: 'GRRTR')),
  ].freeze

  def self.all
    CASE_STAGES
  end
end
