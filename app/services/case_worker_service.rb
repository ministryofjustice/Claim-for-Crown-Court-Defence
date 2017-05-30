class CaseWorkerService
  attr_accessor :current_user, :criteria

  def initialize(current_user:, criteria: {})
    self.current_user = current_user
    self.criteria = criteria
  end

  def active
    Remote::CaseWorker.all(current_user, criteria)
  end
end
