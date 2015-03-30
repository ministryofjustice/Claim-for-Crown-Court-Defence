module Claims::StateMachine
  def self.included(klass)
    klass.state_machine :state, initial: :draft do
      event :submit do
        transition draft: :submitted
      end
    end
  end
end
