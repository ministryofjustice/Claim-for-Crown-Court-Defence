module TagHelper
  STATE_COLOURS =
    {
      'authorised' => 'green',
      'accepted' => 'green',
      'allocated' => 'purple',
      'draft' => 'blue',
      'rejected' => 'red',
      'refused' => 'red',
      'unverified' => 'red',
      'archived_pending_delete' => 'grey',
      'redetermination' => 'grey',
      'part_authorised' => 'blue',
      'submitted' => 'grey'
    }.freeze

  def state_colour(state)
    STATE_COLOURS[state] || 'grey'
  end

  def govuk_tag_active_user?(user)
    if user.active? && user.enabled?
      govuk_tag(text: 'Active',
                colour: 'green')
    else
      govuk_tag(
        text: 'Inactive', colour: 'red'
      )
    end
  end
end
