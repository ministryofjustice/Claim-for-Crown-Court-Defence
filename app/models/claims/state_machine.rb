module Claims::StateMachine
  def self.included(klass)
    klass.state_machine :state, initial: :draft do
      event :submit do
        transition [:draft, :submitted] => :submitted
      end
    end

    klass.scope :draft, -> { klass.where(state: 'draft') }
    klass.scope :submitted, -> { klass.where(state: 'submitted') }
  end
end
