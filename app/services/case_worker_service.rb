class CaseWorkerService
  attr_accessor :current_user, :criteria

  def initialize(current_user:, criteria: {})
    self.current_user = current_user
    self.criteria = criteria
  end

  def remote?
    Settings.case_workers_remote_allocations?
  end

  def active
    if remote?
      Remote::CaseWorker.all(current_user, criteria)
    else
      CaseWorker.active.includes(:user)
    end
  end
end
