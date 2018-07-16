module Stats
  class MIData < ApplicationRecord
    self.table_name = 'mi_data'

    class << self
      def import(claim)
        transformed_attributes = Transform::Claim.call(claim)
        new_mi = Stats::MIData.new(transformed_attributes)
        new_mi.save
      end
    end
  end
end
