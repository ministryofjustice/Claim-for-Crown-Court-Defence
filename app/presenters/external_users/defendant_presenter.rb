module ExternalUsers
  class DefendantPresenter < BasePresenter
    presents :defendant

    def representation_orders = defendant.representation_orders.map { |rep_order| RepresentationOrder.new(rep_order, @view) }
  end
end
