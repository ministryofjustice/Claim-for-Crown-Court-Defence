class ClaimStateTransitionPresenter < BasePresenter
  presents :claim_state_transition

  def transition_message
    state = new_state
    return "#{transition_messages[state][current_user_persona]}"
  end

  def timestamp
    " - #{claim_state_transition.created_at.strftime('%H:%M')}"
  end

private

  def transition_messages
    {
      'redetermination'               => {"CaseWorker" => "Redetermination requested",     "ExternalUser" => "You requested redetermination"},
      'awaiting_written_reasons'      => {"CaseWorker" => "Written reasons requested",     "ExternalUser" => "You requested written reasons"},
      'written_reasons_provided'      => {"CaseWorker" => "Written reasons provided",      "ExternalUser" => "You received written reasons"},
      'submitted'                     => {"CaseWorker" => "Claim submitted",               "ExternalUser" => "Your claim has been submitted"},
      'allocated'                     => {"CaseWorker" => "Claim allocated",               "ExternalUser" => "Your claim has been allocated"},
      'authorised'                    => {"CaseWorker" => "Claim authorised",              "ExternalUser" => "Your claim has been authorised"},
      'part_authorised'               => {"CaseWorker" => "Claim part authorised",         "ExternalUser" => "Your claim has been part-authorised"},
      'rejected'                      => {"CaseWorker" => "Claim rejected",                "ExternalUser" => "Your claim has been rejected"},
      'refused'                       => {"CaseWorker" => "Claim refused",                 "ExternalUser" => "Your claim has been refused"},
      'archived_pending_delete'       => {"CaseWorker" => "Claim archived",                "ExternalUser" => "Your claim has been archived"}
    }
  end

  def current_user_persona
    @view.current_user.persona.class.to_s
  end

  def new_state
    previous_transition.from == 'awaiting_written_reasons' ? 'written_reasons_provided' : claim_state_transition.to
  end

  def all_transitions
    claim_state_transition.claim.claim_state_transitions
  end

  def current_index
    all_transitions.index(claim_state_transition)
  end

  def previous_index
    current_index - 1
  end

  def previous_transition
    all_transitions[previous_index]
  end
end
