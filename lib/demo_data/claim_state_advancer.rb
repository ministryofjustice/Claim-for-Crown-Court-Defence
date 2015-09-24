
module DemoData

  class ClaimStateAdvancer

    TRANSITION_METHODS = {
      'draft'                       => [],
      'submitted'                   => [ :submit ],
      'allocated'                   => [ :submit, :allocate ],
      'rejected'                    => [ :submit, :allocate, :reject ],
      'part_paid'                   => [ :submit, :allocate, :pay_part],
      'paid'                        => [ :submit, :allocate, :pay],
      'awaiting_info_from_court'    => [ :submit, :allocate, :await_info_from_court ],
      'awaiting_further_info'       => [ :submit, :allocate, :pay_part, :await_further_info],
      'refused'                     => [ :submit, :allocate, :refuse ]
    }



    def initialize(claim)
      @claim                = claim
      @case_worker          = User.where("email like '%example.com' and  persona_type = 'CaseWorker'").map(&:persona).sample
    end

    def advance_to(desired_state)
      transition_methods = TRANSITION_METHODS[desired_state]
      transition_methods.each do |method|
        send(method, @claim)
      end
      puts "   Claim advanced to #{desired_state}."
    end


    private

    def add_message(claim, sender)
      FactoryGirl.create :message, sender: sender.user, claim: claim, body: Faker::Lorem.paragraph
    end

    def submit(claim)
      add_message(claim, claim.advocate)
      claim.submit!
    end


    def allocate(claim)
      allocator = ::Allocation.new(case_worker_id: @case_worker.id, claim_ids: [claim.id])
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

    def pay_part(claim)
      add_message(claim, @case_worker)
      claim.save!                 # save in order to update the expense and fee totals
      claim.assessment.update(fees: claim.fees_total * rand(0.5..0.8), expenses: claim.expenses_total * rand(0.5..0.8))
      claim.reload
      claim.pay_part!
    end

    def pay(claim)
      add_message(claim, @case_worker)
      claim.save!                 # save in order to update the expense and fee totals
      claim.assessment.update(fees: claim.fees_total, expenses: claim.expenses_total)
      claim.reload
      claim.pay!
    end


    def await_info_from_court(claim)
      claim.await_info_from_court!
    end

    def await_further_info(claim)
      add_message(claim, @case_worker)
      claim.await_further_info!
    end

    def refuse(claim)
      add_message(claim, @case_worker)
      claim.refuse!
    end

  end

end