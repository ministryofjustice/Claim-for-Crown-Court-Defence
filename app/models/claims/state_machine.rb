module Claims::StateMachine
  def self.included(klass)
    klass.state_machine :state, initial: :draft do
      after_transition on: :submit, do: :set_submission_date!

      event :submit do
        transition [:draft, :submitted] => :submitted
      end
    end

    klass.scope :draft, -> { klass.where(state: 'draft') }
    klass.scope :submitted, -> { klass.where(state: 'submitted') }
  end

  private

  def set_submission_date!
    update_column(:submitted_at, Time.now)
  end
end
