module CaseWorkers
  class DefendantPresenter < BasePresenter
    presents :defendant

    def representation_orders
      defendant.representation_orders.map { |rep_order| RepresentationOrder.new(rep_order, @view) }
    end

    def cases
      LAA::Cda::ProsecutionCase.search(name:, date_of_birth:)
    end
  end
end
