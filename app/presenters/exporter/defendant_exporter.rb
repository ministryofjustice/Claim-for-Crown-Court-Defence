class Exporter::DefendantExporter

  def initialize(defendant)
    @defendant = defendant
  end
  
  def to_h
    {
      defendant: {
        first_name: @defendant.first_name,
        last_name: @defendant.last_name,
        date_of_birth: @defendant.date_of_birth,
        representation_orders: reporder_hash
      }
    }
  end

  private

  def

  end
end