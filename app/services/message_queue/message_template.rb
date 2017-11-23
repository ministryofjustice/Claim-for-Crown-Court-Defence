module MessageQueue
  class MessageTemplate
    def self.claim_created(type, uuid)
      {
        body: 'Claim submitted',
        attributes:
        {
          'type':
        {
          data_type: 'String',
          string_value: type
        },
          'uuid':
          {
            data_type: 'String',
            string_value: uuid
          }
        }
      }
    end
  end
end
