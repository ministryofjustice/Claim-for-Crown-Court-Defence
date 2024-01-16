module CaseWorkers
  class RepresentationOrder < BasePresenter
    presents :representation_order

    def maat_details = @maat_details ||= MaatService.call(maat_reference:)
  end
end