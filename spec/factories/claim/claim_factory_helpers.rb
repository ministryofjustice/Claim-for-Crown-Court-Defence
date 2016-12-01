module ClaimFactoryHelpers

  def add_defendant_and_reporder(claim)
    defendant = create(:defendant, claim: claim)
    create(:representation_order, defendant: defendant, representation_order_date: 380.days.ago)
    claim.reload
  end



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

  def make_claim_creator_advocate_admin(claim)
    advocate_admin = claim.external_user.provider.external_users.where(role:'admin').sample
    advocate_admin ||= create(:external_user, :admin, provider: claim.external_user.provider)
    claim.creator = advocate_admin
  end

  def post_build_actions_for_draft_claim(claim)
    certify_claim(claim)
    add_misc_fees(claim)
    set_creator(claim)
    populate_required_fields(claim)
  end

  def certify_claim(claim)
    build(:certification, claim: claim)
  end

  def add_misc_fees(claim)
    claim.fees << build(:misc_fee, claim: claim)
  end

  def set_creator(claim)
    claim.creator = claim.external_user
  end

end


