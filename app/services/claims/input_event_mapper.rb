module Claims
  class InputEventMapper
    FORM_INPUT_EVENTS = {
      'authorised'               => :authorise!,
      'part_authorised'          => :authorise_part!,
      'rejected'                 => :reject!,
      'refused'                  => :refuse!,
      'redetermination'          => :redetermine!
    }.freeze

    def self.input_event(input)
      new(input).event
    end

    def initialize(input)
      @input = input
    end

    def event
      FORM_INPUT_EVENTS[@input]
    end
  end
end
