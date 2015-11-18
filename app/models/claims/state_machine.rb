module Claims::StateMachine
  ARCHIVE_VALIDITY = 180.days
  STANDARD_VALIDITY = 21.days

  ADVOCATE_DASHBOARD_DRAFT_STATES               = %w( draft )
  ADVOCATE_DASHBOARD_REJECTED_STATES            = %w( rejected )
  ADVOCATE_DASHBOARD_SUBMITTED_STATES           = %w( allocated submitted )
  ADVOCATE_DASHBOARD_PART_AUTHORISED_STATES     = %w( part_authorised )
  ADVOCATE_DASHBOARD_COMPLETED_STATES           = %w( refused authorised )
  CASEWORKER_DASHBOARD_COMPLETED_STATES         = %w( authorised part_authorised rejected refused )
  CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES  = %w( allocated )
  CASEWORKER_DASHBOARD_UNALLOCATED_STATES       = %w( submitted redetermination awaiting_written_reasons )
  CASEWORKER_DASHBOARD_ARCHIVED_STATES          = %w( authorised part_authorised rejected refused archived_pending_delete)
  VALID_STATES_FOR_REDETERMINATION              = %w( authorised part_authorised refused )
  VALID_STATES_FOR_ARCHIVAL                     = %w( authorised part_authorised refused rejected )
  NON_DRAFT_STATES                              = %w( allocated deleted authorised part_authorised refused rejected submitted )
  AUTHORISED_STATES                             = ADVOCATE_DASHBOARD_PART_AUTHORISED_STATES + ADVOCATE_DASHBOARD_COMPLETED_STATES

  def self.dashboard_displayable_states
    ADVOCATE_DASHBOARD_DRAFT_STATES +
    ADVOCATE_DASHBOARD_REJECTED_STATES +
    ADVOCATE_DASHBOARD_SUBMITTED_STATES +
    ADVOCATE_DASHBOARD_PART_AUTHORISED_STATES +
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
            :awaiting_written_reasons,
            :deleted,
            :draft,
            :authorised,
            :part_authorised,
            :refused,
            :rejected,
            :redetermination,
            :submitted

      after_transition on: :submit,                   do: [:set_last_submission_date!, :set_original_submission_date!]
      after_transition on: :authorise,                do: :set_authorised_date!
      after_transition on: :authorise_part,           do: :set_authorised_date!
      after_transition on: :redetermine,              do: [:remove_case_workers!, :set_last_submission_date!]
      after_transition on: :await_written_reasons,    do: [:remove_case_workers!, :set_last_submission_date!]
      after_transition on: :archive_pending_delete,   do: :set_valid_until!
      before_transition on: [:reject, :refuse], do: :set_amount_assessed_zero!
      before_transition any => any,  do: :set_paper_trail_event!

      event :redetermine do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :redetermination
      end

      event :await_written_reasons do
        transition VALID_STATES_FOR_REDETERMINATION.map(&:to_sym) => :awaiting_written_reasons
      end

      event :allocate do
        transition [:submitted, :redetermination, :awaiting_written_reasons] => :allocated
      end

      event :archive_pending_delete do
        transition all => :archived_pending_delete
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

    klass.scope :submitted_or_redetermination_or_awaiting_written_reasons, -> { klass.where(state: CASEWORKER_DASHBOARD_UNALLOCATED_STATES) }

    klass.scope :advocate_dashboard_draft,                -> { klass.where(state: ADVOCATE_DASHBOARD_DRAFT_STATES )             }
    klass.scope :advocate_dashboard_rejected,             -> { klass.where(state: ADVOCATE_DASHBOARD_REJECTED_STATES )          }
    klass.scope :advocate_dashboard_submitted,            -> { klass.where(state: ADVOCATE_DASHBOARD_SUBMITTED_STATES )         }
    klass.scope :advocate_dashboard_part_authorised,      -> { klass.where(state: ADVOCATE_DASHBOARD_PART_AUTHORISED_STATES )   }
    klass.scope :advocate_dashboard_completed,            -> { klass.where(state: ADVOCATE_DASHBOARD_COMPLETED_STATES )         }
    klass.scope :caseworker_dashboard_completed,          -> { klass.where(state: CASEWORKER_DASHBOARD_COMPLETED_STATES)        }
    klass.scope :caseworker_dashboard_under_assessment,   -> { klass.where(state: CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES) }
    klass.scope :caseworker_dashboard_archived,           -> { klass.where(state: CASEWORKER_DASHBOARD_ARCHIVED_STATES)         }

  end

  private

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
