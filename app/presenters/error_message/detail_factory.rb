module ErrorMessage
  class DetailFactory
    def initialize(sequencer:)
      @sequencer = sequencer
    end

    def build(attribute, message)
      Detail.new(
        attribute,
        message.long,
        message.short,
        message.api,
        @sequencer.generate(attribute)
      )
    end
  end
end
