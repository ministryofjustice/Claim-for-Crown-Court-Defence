class StateChangePresenter < BasePresenter

  presents :version

  def new_state?
    true
  end

  def change
    version.changeset.each do |attribute, changes|
      new_state = changes.last
      return "#{descriptions[new_state]} - #{version.created_at.strftime('%H:%M')}"
    end
  end

  def descriptions
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
