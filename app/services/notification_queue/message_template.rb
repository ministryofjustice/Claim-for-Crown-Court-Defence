module NotificationQueue
  class MessageTemplate
    def self.for_claim(arn, claim)
      {
        topic_arn: arn,
        message: 'Claim created',
        message_structure: 'messageStructure',
        message_attributes: {
          'claim_type' => { data_type: 'String', string_value: claim.type },
          'uuid' => { data_type: 'String', string_value: claim.uuid }
        }
      }
    end
  end
end
