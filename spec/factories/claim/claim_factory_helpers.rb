module ClaimFactoryHelpers

  def allocate_claim(claim)

    publicise_errors(claim) { claim.submit! }
    case_worker = create :case_worker
    case_worker_admin = create :case_worker, :admin
    allocator_options = {
      current_user: case_worker_admin.user,
      case_worker_id: case_worker.id,
      claim_ids: [claim.id],
      deallocate: false,
      allocating: true
    }
    allocator = Allocation.new(allocator_options)
    allocator.save
  end


  def authorise_claim(claim)
    allocate_claim(claim)
    claim.reload
    set_amount_assessed(claim)
    claim.authorise!
    claim.last_decision_transition.update_author_id(claim.case_workers.first.user.id)
  end

end