module Claims::StateMachine
  ARCHIVE_VALIDITY = 180.days
  STANDARD_VALIDITY = 21.days

  ADVOCATE_DASHBOARD_DRAFT_STATES             = %w( draft )
  ADVOCATE_DASHBOARD_REJECTED_STATES          = %w( rejected )
  ADVOCATE_DASHBOARD_SUBMITTED_STATES         = %w( allocated submitted awaiting_info_from_court awaiting_further_info )
  ADVOCATE_DASHBOARD_PART_PAID_STATES         = %w( part_paid )
  ADVOCATE_DASHBOARD_COMPLETED_STATES         = %w( refused paid )
  CASEWORKER_DASHBOARD_COMPLETED_STATES       = %w( paid part_paid rejected refused awaiting_further_info awaiting_info_from_court )
  CASEWORKER_DASHBOARD_UNDER_ASSSSMENT_STATES = %w( allocated )
  VALID_STATES_FOR_REDETERMINATION            = %w( paid part_paid refused )
  NON_DRAFT_STATES                            = %w( allocated awaiting_further_info awaiting_info_from_court deleted paid part_paid refused rejected submitted )
  PAID_STATES                                 = ADVOCATE_DASHBOARD_PART_PAID_STATES + ADVOCATE_DASHBOARD_COMPLETED_STATES

  def self.advocate_dashboard_displayable_states
    ADVOCATE_DASHBOARD_DRAFT_STATES +
    ADVOCATE_DASHBOARD_REJECTED_STATES +
    ADVOCATE_DASHBOARD_SUBMITTED_STATES +
    ADVOCATE_DASHBOARD_PART_PAID_STATES +
    ADVOCATE_DASHBOARD_COMPLETED_STATES
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
      audit_trail

      state :allocated,
            :archived_pending_delete,
            :awaiting_further_info,
            :awaiting_info_from_court,
            :awaiting_written_reasons,
            :deleted,
            :draft,
            :paid,
            :part_paid,
            :refused,
            :rejected,
            :redetermination,
            :submitted

      after_transition on: :submit,                   do: :set_submission_date!
      after_transition on: :pay,                      do: :set_paid_date!
      after_transition on: :pay_part,                 do: :set_paid_date!
      after_transition on: :redetermine,              do: :remove_case_workers!
      after_transition on: :await_written_reasons,    do: :remove_case_workers!
      after_transition on: :await_further_info,       do: :set_valid_until!
      after_transition on: :archive_pending_delete,   do: :set_valid_until!
      before_transition on: [:await_info_from_court, :reject, :refuse], do: :set_amount_assessed_zero!
      before_transition any => any,  do: :set_paper_trail_event!

      event :redetermine do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :redetermination
      end

      event :await_written_reasons do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :awaiting_written_reasons
      end

      event :allocate do
        transition [:submitted, :awaiting_info_from_court, :redetermination, :awaiting_written_reasons] => :allocated
      end

      event :archive_pending_delete do
        transition all => :archived_pending_delete
      end

      event :await_info_from_court do
        transition [:allocated] => :awaiting_info_from_court
      end

      event :await_further_info do
        transition [:part_paid] => :awaiting_further_info
      end

      event :pay_part do
        transition [:allocated] => :part_paid
      end

      event :pay do
        transition [:allocated] => :paid
      end

      event :refuse do
        transition [:allocated] => :refused
      end

      event :reject do
        transition [:allocated] => :rejected
      end

      event :submit do
        transition [:draft, :allocated] => :submitted
      end

    end

    klass.state_machine.states.map(&:name).each do |s|
      klass.scope s, -> { klass.where(state: s) }
    end

    klass.scope :non_draft, -> { klass.where(state: NON_DRAFT_STATES) }

    klass.scope :submitted_or_redetermination_or_awaiting_written_reasons, -> { klass.where(state: %w(submitted redetermination awaiting_written_reasons) ) }

    klass.scope :advocate_dashboard_draft,                -> { klass.where(state: ADVOCATE_DASHBOARD_DRAFT_STATES )           }
    klass.scope :advocate_dashboard_rejected,             -> { klass.where(state: ADVOCATE_DASHBOARD_REJECTED_STATES )        }
    klass.scope :advocate_dashboard_submitted,            -> { klass.where(state: ADVOCATE_DASHBOARD_SUBMITTED_STATES )       }
    klass.scope :advocate_dashboard_part_paid,            -> { klass.where(state: ADVOCATE_DASHBOARD_PART_PAID_STATES )       }
    klass.scope :advocate_dashboard_completed,            -> { klass.where(state: ADVOCATE_DASHBOARD_COMPLETED_STATES )       }
    klass.scope :caseworker_dashboard_completed,          -> { klass.where(state: CASEWORKER_DASHBOARD_COMPLETED_STATES)      }
    klass.scope :caseworker_dashboard_under_assessment,   -> { klass.where(state: CASEWORKER_DASHBOARD_UNDER_ASSSSMENT_STATES)}

  end

  private

  def set_submission_date!
    update_column(:submitted_at, Time.now)
  end

  def set_paid_date!
    update_column(:paid_at, Time.now)
  end

  def set_valid_until!(transition)
    validity = (transition.to == 'archived_pending_delete') ? ARCHIVE_VALIDITY : STANDARD_VALIDITY
    update_column(:valid_until, Time.now + validity)
  end

  def set_paper_trail_event!
    self.paper_trail_event = 'State change'
  end

  def set_amount_assessed_zero!
    self.assessment.zeroize! if self.state == 'allocated'
  end

  def remove_case_workers!
    self.case_workers.destroy_all
  end
end
