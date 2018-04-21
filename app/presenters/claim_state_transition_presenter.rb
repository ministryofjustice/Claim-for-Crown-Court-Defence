class ClaimStateTransitionPresenter < BasePresenter
  presents :transition

  def transition_message
    transition_messages[transition.to][current_user_persona]
  end

  def timestamp
    transition.created_at.strftime('%H:%M')
  end

  def audit_users
    return '(System)' if transition.author.nil? || hide_author?
    sentence = allocation? ? '%{author} to %{subject}' : '%{author}'
    format(sentence, author: transition.author.name, subject: transition.subject&.name)
  end

  def reason_header
    "#{'Reason'.pluralize(transition.reason.size)} provided:"
  end

  def reason_descriptions
    transition.reason.each_with_object([]) do |reason, arr|
      description = reason.description
      other_description = " (#{transition.reason_text})" if description.eql?('Other') && reason_text.present?
      description = "#{description}#{other_description}"
      yield description if block_given?
      arr << description
    end
  end

  private

  def transition_messages
    {
      'redetermination' => {
        'CaseWorker' => 'Redetermination requested', 'ExternalUser' => 'You requested redetermination'
      },
      'awaiting_written_reasons' => {
        'CaseWorker' => 'Written reasons requested', 'ExternalUser' => 'You requested written reasons'
      },
      'submitted' => {
        'CaseWorker' => 'Claim submitted', 'ExternalUser' => 'Your claim has been submitted'
      },
      'allocated' => {
        'CaseWorker' => 'Claim allocated', 'ExternalUser' => 'Your claim has been allocated'
      },
      'deallocated' => {
        'CaseWorker' => 'Claim de-allocated', 'ExternalUser' => 'Your claim has been de-allocated'
      },
      'authorised' => {
        'CaseWorker' => 'Claim authorised', 'ExternalUser' => 'Your claim has been authorised'
      },
      'part_authorised' => {
        'CaseWorker' => 'Claim part authorised', 'ExternalUser' => 'Your claim has been part-authorised'
      },
      'rejected' => {
        'CaseWorker' => 'Claim rejected', 'ExternalUser' => 'Your claim has been rejected'
      },
      'refused' => {
        'CaseWorker' => 'Claim refused', 'ExternalUser' => 'Your claim has been refused'
      },
      'archived_pending_delete' => {
        'CaseWorker' => 'Claim archived', 'ExternalUser' => 'Your claim has been archived'
      }
    }
  end

  def current_user_persona
    h.current_user.persona.class.to_s
  end

  def all_transitions
    @all_transitions ||= transition.claim.reload.claim_state_transitions
  end

  def current_index
    all_transitions.index(transition)
  end

  # Transitions are ordered: 'created_at desc'
  def previous_transition
    all_transitions[current_index + 1]
  end

  def hide_author?
    h.current_user_is_external_user? && (h.current_user != transition.author)
  end

  def allocation?
    transition.to == 'allocated'
  end
end
