# when including this module you will need to define
# a steps method for the including class that
# contains an array of named/symbol steps.
#
module NamedSteppable
  extend ActiveSupport::Concern

  included do
    attr_writer :current_step

    def current_step
      @current_step || steps.first
    end

    def current_step_index
      steps.index(current_step)
    end

    def step?(step)
      current_step == step
    end

    def next_step
      steps[current_step_index + 1]
    end

    def next_step!
      self.form_step = self.current_step = next_step
    end
  end
end
