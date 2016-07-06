
module DemoData

  class ClaimStateAdvancer

    TRANSITION_METHODS = {
      'draft'                     => [],
      'submitted'                 => [ :submit ],
      'allocated'                 => [ :submit, :allocate ],
      'rejected'                  => [ :submit, :allocate, :reject ],
      'part_authorised'           => [ :submit, :allocate, :authorise_part],
      'authorised'                => [ :submit, :allocate, :authorise],
      'refused'                   => [ :submit, :allocate, :refuse ],
      'redetermination'           => [ :submit, :allocate, :authorise, :redetermine ],
      'awaiting_written_reasons'  => [ :submit, :allocate, :authorise, :await_written_reasons ]
    }

    def initialize(claim)
      @claim                = claim
      @case_worker          = User.where("email like '%example.com' and  persona_type = 'CaseWorker'").map(&:persona).sample
      @advocate             = User.where("email like '%example.com' and  persona_type = 'ExternalUser'").map(&:persona).sample
    end

    def advance_to(desired_state)
      transition_methods = TRANSITION_METHODS[desired_state]
      transition_methods.each do |method|
        send(method, @claim)
      end
      puts "   Claim advanced to #{desired_state}."
    end

    def advance_from_allocated_to(desired_state)
      transition_method = TRANSITION_METHODS[desired_state].last
      send(transition_method, @claim)
    end

    private

    def add_message(claim, sender)
      Message.create(claim: claim, sender: sender.user, body: Faker::Lorem.paragraph)
    end

    def submit(claim)
      add_message(claim, claim.external_user)
      claim.update(last_submitted_at: rand(0..180).days.ago)
      claim.submit!
    end


    def allocate(claim)
      allocator = ::Allocation.new(case_worker_id: @case_worker.id, claim_ids: [claim.id], allocating: true)
      unless allocator.save
        raise RuntimeError.new("Unable to allocate claim #{claim.id} to case_worker #{@case_worker.id}")
      end
      add_message(claim, @case_worker)
      claim.allocate!
    end

    def reject(claim)
      add_message(claim, @case_worker)
      claim.reject!
    end

    def authorise_part(claim)
      add_message(claim, @case_worker)
      claim.save!                 # save in order to update the expense and fee totals
      claim.assessment.update(
          fees: claim.fees_total * rand(0.5..0.8),
          expenses: claim.expenses_total * rand(0.5..0.8),
          disbursements: claim.disbursements_total * rand(0.5..0.8))
      claim.reload
      claim.authorise_part!
    end

    def authorise(claim)
      add_message(claim, @case_worker)
      claim.save!                 # save in order to update the expense and fee totals
      claim.assessment.update(
          fees: claim.fees_total,
          expenses: claim.expenses_total,
          disbursements: claim.disbursements_total)
      claim.reload
      claim.authorise!
    end

    def refuse(claim)
      add_message(claim, @case_worker)
      claim.refuse!
    end

    def redetermine(claim)
      add_message(claim, @advocate)
      claim.redetermine!
    end

    def await_written_reasons(claim)
      add_message(claim, @advocate)
      claim.redetermine!
    end

  end

end