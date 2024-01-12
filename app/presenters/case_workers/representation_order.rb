module CaseWorkers
  class RepresentationOrder < BasePresenter
    presents :representation_order

    def maat_details
      connection = Faraday.new('http://localhost:8090/api/internal/v1')
      data = JSON.parse(connection.get("assessment/rep-orders/#{representation_order.maat_reference}").body)
      { case_number: data['caseId'] }
    end
  end
end