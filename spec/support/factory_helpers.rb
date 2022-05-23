# Custom helpers to mixin for use in factorybot
#
module FactoryHelpers
  def add_defendant_and_reporder(claim, representation_order_date = nil)
    defendant = if representation_order_date
                  create(:defendant, :without_reporder, claim:)
                else
                  create(:defendant, claim:)
                end
    create(
      :representation_order,
      defendant:,
      representation_order_date: representation_order_date&.to_date || 380.days.ago
    )
    claim.reload
  end

  def allocate_claim(claim)
    publicise_errors(claim) { claim.submit! }
    case_worker = create(:case_worker)
    case_worker_admin = create(:case_worker, :admin)
    allocator_options = {
      current_user: case_worker_admin.user,
      case_worker_id: case_worker.id,
      claim_ids: [claim.id],
      deallocate: false,
      allocating: true
    }
    allocator = Allocation.new(allocator_options)
    allocator.save
    claim.reload
  end

  def authorise_claim(claim)
    allocate_claim(claim)
    assign_fees_and_expenses_for(claim)
    claim.authorise!({ author_id: claim.case_workers.first.user.id })
  end

  def advance_to_pending_delete(claim)
    allocate_claim(claim)
    claim.reload
    assign_fees_and_expenses_for(claim)
    claim.authorise!
    claim.archive_pending_delete!
  end

  def advance_to_pending_review(claim)
    allocate_claim(claim)
    claim.reload
    assign_fees_and_expenses_for(claim)
    claim.authorise!
    claim.archive_pending_review!
  end

  def make_claim_creator_advocate_admin(claim)
    advocate_admin = claim.external_user.provider.external_users.admins.sample
    advocate_admin ||= create(:external_user, :admin, provider: claim.external_user.provider)
    claim.creator = advocate_admin
  end

  def post_build_actions_for_draft_final_claim(claim)
    certify_claim(claim)
    add_fee(:misc_fee, claim)
    assign_external_user_as_creator(claim)
    populate_required_fields(claim)
  end

  def post_build_actions_for_draft_hardship_claim(claim)
    certify_claim(claim)
    assign_external_user_as_creator(claim)
    populate_required_fields(claim)
  end

  def certify_claim(claim)
    build(:certification, claim:)
  end

  # usage:
  # * add_fee(:misc_fee, claim)
  # * add_fee(:fixed_fee, claim)
  #
  def add_fee(factory, claim)
    claim.fees << build(factory, claim:)
  end

  def assign_external_user_as_creator(claim)
    claim.creator = claim.external_user
  end
end
