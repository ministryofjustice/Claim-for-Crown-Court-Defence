class ClaimStateTransitionPresenter < BasePresenter

  presents :claim_state_transition

  def transition_message
    new_state = claim_state_transition.to
    return "#{transition_messages[new_state][current_user_persona]}"
  end

  def timestamp
    " - #{claim_state_transition.created_at.strftime('%H:%M')}"
  end

private

  def transition_messages
    {
      'redetermination'               => {"CaseWorker" => "Redetermination requested",     "ExternalUser" => "You requested redetermination"},
      'awaiting_written_reasons'      => {"CaseWorker" => "Written reasons requested",     "ExternalUser" => "You requested written reasons"},
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

end
