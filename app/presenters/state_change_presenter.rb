class StateChangePresenter < BasePresenter

  presents :version

  def change
    if version.changeset['state'].present?
      new_state = version.changeset['state'].last
      return "#{state_change_descriptions[new_state][current_user_persona]}"
    end
  end

  def timestamp
    " - #{version.created_at.strftime('%H:%M')}"
  end

private

  def state_change_descriptions
    {
      'redetermination'               => {"CaseWorker" => "Redetermination requested",     "Advocate" => "You requested redetermination"},
      'awaiting_written_reasons'      => {"CaseWorker" => "Written reasons requested",     "Advocate" => "You requested written reasons"},
      'submitted'                     => {"CaseWorker" => "Claim submitted",               "Advocate" => "Your claim has been submitted"},
      'allocated'                     => {"CaseWorker" => "Claim allocated",               "Advocate" => "Your claim has been allocated"},
      'authorised'                    => {"CaseWorker" => "Claim authorised",              "Advocate" => "Your claim has been authorised"},
      'part_authorised'               => {"CaseWorker" => "Claim part authorised",         "Advocate" => "Your claim has been part-authorised"},
      'rejected'                      => {"CaseWorker" => "Claim rejected",                "Advocate" => "Your claim has been rejected"},
      'refused'                       => {"CaseWorker" => "Claim refused",                 "Advocate" => "Your claim has been refused"}
    }
  end

  def current_user_persona
    @view.current_user.persona.class.to_s
  end

end
