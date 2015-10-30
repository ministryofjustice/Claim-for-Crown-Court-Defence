class StateChangePresenter < BasePresenter

  presents :version

  def change
    version.changeset.each do |attribute, changes|
      new_state = changes.last
      return "#{state_change_descriptions[new_state]} - #{version.created_at.strftime('%H:%M')}"
    end
  end

private

  def state_change_descriptions
    {
      'redetermiation'                => 'Redetermination requested',
      'awaiting_written_reasons'      => 'Written reasons requested',
      'submitted'                     => 'Claim submitted',
      'allocated'                     => 'Claim allocated',
      'authorised'                    => 'Claim authorised',
      'part_autorised'                => 'Claim part authorised',
      'rejected'                      => 'Claim rejected',
      'refused'                       => 'Claim refused'
    }
  end

end
