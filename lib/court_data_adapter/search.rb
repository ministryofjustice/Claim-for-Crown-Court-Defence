module CourtDataAdaptor
  class Search
    def self.call(**) = new(**).call

    def initialize(**kwargs)
      @params = kwargs
    end

    def call
      CourtDataAdaptor::Resource::ProsecutionCase.where(**@params).includes(defendants: :offences).all
    end
  end
end
