module CaseWorkers
  class DefendantPresenter < BasePresenter
    presents :defendant

    def representation_orders
      defendant.representation_orders.map { |rep_order| RepresentationOrder.new(rep_order, @view) }
    end

    def cases
      @cases ||= CourtDataAdaptor::Search.call(name:, date_of_birth:)
    end
  end
end
