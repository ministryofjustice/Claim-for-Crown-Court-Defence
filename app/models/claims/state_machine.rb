module Claims::StateMachine
  ARCHIVE_VALIDITY  = 180.days
  STANDARD_VALIDITY = 21.days

  EXTERNAL_USER_DASHBOARD_DRAFT_STATES            = %w( draft )
  EXTERNAL_USER_DASHBOARD_REJECTED_STATES         = %w( rejected )
  EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES        = %w( allocated submitted )
  EXTERNAL_USER_DASHBOARD_PART_AUTHORISED_STATES  = %w( part_authorised )
  EXTERNAL_USER_DASHBOARD_COMPLETED_STATES        = %w( refused authorised )
  CASEWORKER_DASHBOARD_COMPLETED_STATES           = %w( authorised part_authorised rejected refused )
  CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES    = %w( allocated )
  CASEWORKER_DASHBOARD_UNALLOCATED_STATES         = %w( submitted redetermination awaiting_written_reasons )
  CASEWORKER_DASHBOARD_ARCHIVED_STATES            = %w( authorised part_authorised rejected refused archived_pending_delete)
  VALID_STATES_FOR_REDETERMINATION                = %w( authorised part_authorised refused )
  VALID_STATES_FOR_ARCHIVAL                       = %w( authorised part_authorised refused rejected )
  VALID_STATES_FOR_ALLOCATION                     = %w( submitted redetermination awaiting_written_reasons )
  VALID_STATES_FOR_DEALLOCATION                   = %w( allocated )
  NON_DRAFT_STATES                                = %w( allocated authorised part_authorised refused rejected submitted awaiting_written_reasons redetermination archived_pending_delete)
  AUTHORISED_STATES                               = EXTERNAL_USER_DASHBOARD_PART_AUTHORISED_STATES + EXTERNAL_USER_DASHBOARD_COMPLETED_STATES

  def self.dashboard_displayable_states
    (
      EXTERNAL_USER_DASHBOARD_DRAFT_STATES +
      EXTERNAL_USER_DASHBOARD_REJECTED_STATES +
      EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES +
      CASEWORKER_DASHBOARD_UNALLOCATED_STATES +
      EXTERNAL_USER_DASHBOARD_PART_AUTHORISED_STATES +
      EXTERNAL_USER_DASHBOARD_COMPLETED_STATES
    ).uniq
  end

  # will return true if there is a constant defined in this class with the same name in upper case as method with the trailing question mark removed
  def self.has_state?(method)
    return false unless method =~ /\?$/
    const_defined?("#{method.to_s.chop.upcase}_STATES")
  end


  def self.is_in_state?(method, claim)
    begin
      konstant_name = "Claims::StateMachine::#{method.to_s.chop.upcase}_STATES".constantize
      konstant_name.include?(claim.state)
    rescue NameError
      return false
    end
  end

  def self.included(klass)
    klass.state_machine :state, initial: :draft do
      audit_trail class: ClaimStateTransition, context: [:reason_code]

      state :allocated,
            :archived_pending_delete,
            :awaiting_written_reasons,
            :deleted,
            :draft,
            :authorised,
            :part_authorised,
            :refused,
            :rejected,
            :redetermination,
            :submitted,
            :deallocated

      after_transition on: :submit,                   do: [:set_last_submission_date!, :set_original_submission_date!]
      after_transition on: :authorise,                do: :set_authorised_date!
      after_transition on: :authorise_part,           do: :set_authorised_date!
      after_transition on: :redetermine,              do: [:remove_case_workers!, :set_last_submission_date!]
      after_transition on: :await_written_reasons,    do: [:remove_case_workers!, :set_last_submission_date!]
      after_transition on: :archive_pending_delete,   do: :set_valid_until!
      before_transition on: [:reject, :refuse],       do: :set_amount_assessed_zero!
      after_transition  on: :deallocate,              do: :reset_state
      before_transition on: :submit,                  do: :set_allocation_type

      event :redetermine do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :redetermination
      end

      event :await_written_reasons do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :awaiting_written_reasons
      end

      event :allocate do
        transition VALID_STATES_FOR_ALLOCATION.map(&:to_sym) => :allocated
      end

      event :deallocate do
        transition VALID_STATES_FOR_DEALLOCATION.map(&:to_sym) => :deallocated
        # transition [:allocated] => :deallocated
      end

      event :archive_pending_delete do
        transition VALID_STATES_FOR_ARCHIVAL.map(&:to_sym) => :archived_pending_delete
      end

      event :authorise_part do
        transition [:allocated] => :part_authorised
      end

      event :authorise do
        transition [:allocated] => :authorised
      end

      event :refuse do
        transition [:allocated] => :refused
      end

      event :reject do
        transition [:allocated] => :rejected, :if => :rejectable?
      end

      event :submit do
        transition [:draft, :allocated] => :submitted
      end

      event :transition_clone_to_draft do
        transition [:rejected] => :draft
      end
    end

    klass.state_machine.states.map(&:name).each do |s|
      klass.scope s, -> { klass.where(state: s) }
    end

    klass.scope :non_draft, -> { klass.where(state: NON_DRAFT_STATES) }

    klass.scope :submitted_or_redetermination_or_awaiting_written_reasons, -> { klass.where(state: CASEWORKER_DASHBOARD_UNALLOCATED_STATES) }

    klass.scope :external_user_dashboard_draft,           -> { klass.where(state: EXTERNAL_USER_DASHBOARD_DRAFT_STATES ) }
    klass.scope :external_user_dashboard_rejected,        -> { klass.where(state: EXTERNAL_USER_DASHBOARD_REJECTED_STATES ) }
    klass.scope :external_user_dashboard_submitted,       -> { klass.where(state: EXTERNAL_USER_DASHBOARD_SUBMITTED_STATES ) }
    klass.scope :external_user_dashboard_part_authorised, -> { klass.where(state: EXTERNAL_USER_DASHBOARD_PART_AUTHORISED_STATES ) }
    klass.scope :external_user_dashboard_completed,       -> { klass.where(state: EXTERNAL_USER_DASHBOARD_COMPLETED_STATES ) }
    klass.scope :caseworker_dashboard_completed,          -> { klass.where(state: CASEWORKER_DASHBOARD_COMPLETED_STATES) }
    klass.scope :caseworker_dashboard_under_assessment,   -> { klass.where(state: CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES) }
    klass.scope :caseworker_dashboard_archived,           -> { klass.where(state: CASEWORKER_DASHBOARD_ARCHIVED_STATES) }

    def reason_code(transition)
      options = transition.args&.extract_options!
      options&.[](:reason_code)
    end
  end

  def last_state_transition
    claim_state_transitions.first
  end

  def last_state_transition_reason
    last_state_transition.reason
  end

  def last_state_transition_time
    last_state_transition.created_at
  end

  def filtered_last_state_transition
    claim_state_transitions.where.not(to: %w(allocated deallocated)).first
  end

  private

  def reset_state
    update_column(:state, state_at_last_submission)
  end

  def state_at_last_submission
    self.claim_state_transitions.find { |transition| CASEWORKER_DASHBOARD_UNALLOCATED_STATES.include?(transition.to) }.to
  end

  def set_original_submission_date!
    update_column(:original_submission_date, Time.now)
  end

  def set_last_submission_date!
    update_column(:last_submitted_at, Time.now)
  end

  def set_authorised_date!
    update_column(:authorised_at, Time.now)
  end

  def set_valid_until!(transition)
    validity = (transition.to == 'archived_pending_delete') ? ARCHIVE_VALIDITY : STANDARD_VALIDITY
    update_column(:valid_until, Time.now + validity)
  end

  def set_amount_assessed_zero!
    self.assessment.zeroize! if self.state == 'allocated'
  end

  def set_allocation_type
    self.set_allocation_type
  end

  def remove_case_workers!
    self.case_workers.destroy_all
  end
end
