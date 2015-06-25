module Claims::StateMachine
  ARCHIVE_VALIDITY = 180.days
  STANDARD_VALIDITY = 21.days

  ADVOCATE_DASHBOARD_DRAFT_STATES         = [ 'draft' ]
  ADVOCATE_DASHBOARD_REJECTED_STATES      = [ 'rejected' ]
  ADVOCATE_DASHBOARD_SUBMITTED_STATES     = [ 'allocated', 'submitted', 'awaiting_info_from_court', 'awaiting_further_info' ]
  ADVOCATE_DASHBOARD_PART_PAID_STATES     = [ 'part_paid', 'appealed', 'parts_rejected' ]
  ADVOCATE_DASHBOARD_COMPLETED_STATES     = [ 'completed', 'refused', 'paid' ]

  def self.dashboard_displayable_states
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
    klass.state_machine :state,                      initial: :draft do
      after_transition on: :submit,                  do: :set_submission_date!
      after_transition on: :pay,                     do: :set_paid_date!
      after_transition on: :pay_part,                do: :set_paid_date!
      after_transition on: :appeal,                  do: :set_valid_until!
      after_transition on: :await_further_info,      do: :set_valid_until!
      after_transition on: :reject_parts,            do: :set_valid_until!
      after_transition on: :archive_pending_delete,  do: :set_valid_until!

      state :allocated, :appealed, :archived_pending_delete, :awaiting_further_info, :awaiting_info_from_court, :completed,
         :deleted, :draft, :paid, :part_paid, :parts_rejected, :refused, :rejected, :submitted

      event :allocate do
        transition [:submitted, :awaiting_info_from_court] => :allocated
      end

      event :appeal do
        transition [:parts_rejected] => :appealed
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

      event :complete do
        transition [:appealed, :awaiting_further_info, :paid, :parts_rejected, :refused] => :completed
      end

      event :draft do
        transition [:awaiting_further_info, :rejected] => :draft
      end

      event :pay_part do
        transition [:allocated] => :part_paid
      end

      event :pay do
        transition [:allocated, :appealed] => :paid
      end

      event :refuse do
        transition [:allocated] => :refused
      end

      event :reject do
        transition [:allocated] => :rejected
      end

      event :reject_parts do
        transition [:part_paid] => :parts_rejected
      end

      event :submit do
        transition [:draft] => :submitted
      end

    end

    klass.state_machine.states.map(&:name).each do |s|
      if s == :archived_pending_delete
        klass.scope s, -> { klass.unscope(:where).where(state: s) }
      else
        klass.scope s, -> { klass.where(state: s) }
      end
    end



    # klass.scope :not_deleted, -> { klass.where.not(state: 'archived_pending_delete') }
    klass.scope :non_draft, -> { klass.where(state: ['allocated', 'appealed', 'awaiting_further_info', 'awaiting_info_from_court', 'completed',
         'deleted', 'paid', 'part_paid', 'parts_rejected', 'refused', 'rejected', 'submitted']) }

    klass.scope :advocate_dashboard_draft,      -> { klass.where(state: ADVOCATE_DASHBOARD_DRAFT_STATES ) }
    klass.scope :advocate_dashboard_rejected,   -> { klass.where(state: ADVOCATE_DASHBOARD_REJECTED_STATES ) }
    klass.scope :advocate_dashboard_submitted,  -> { klass.where(state: ADVOCATE_DASHBOARD_SUBMITTED_STATES ) }
    klass.scope :advocate_dashboard_part_paid,  -> { klass.where(state: ADVOCATE_DASHBOARD_PART_PAID_STATES ) }
    klass.scope :advocate_dashboard_completed,  -> { klass.where(state: ADVOCATE_DASHBOARD_COMPLETED_STATES ) }

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

end
