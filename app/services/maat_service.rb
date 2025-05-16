class MaatService
  def self.call(...) = new(...).call

  def initialize(**kwargs)
    @connection = MaatService::Connection.instance
    @maat_reference = kwargs[:maat_reference]
  end

  def call
    data = @connection.fetch(@maat_reference)

    {
      case_number: data['caseId'],
      representation_order_date: data['crownRepOrderDate'],
      asn: data['arrestSummonsNo']
    }
  end
end
