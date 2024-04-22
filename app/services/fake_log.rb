class FakeLog

  def send(payload1, payload2)
    LogStuff.send(
      :error, 'fake',
      payload1:
    ) do
      "Fake log. Payload2: (#{payload2})"
    end
  end

end
