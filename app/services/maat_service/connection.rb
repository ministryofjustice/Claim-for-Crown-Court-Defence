class MaatService
  class Connection
    include Singleton

    def fetch(maat_reference)
      JSON.parse(client.get("assessment/rep-orders/#{maat_reference}").body)
    rescue Faraday::ConnectionFailed
      {}
    end

    private

    def client = @client ||= Faraday.new('http://localhost:8090/api/internal/v1', request: { timeout: 2 })
  end
end
