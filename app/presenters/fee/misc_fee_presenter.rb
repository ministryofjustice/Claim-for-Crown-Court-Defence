module Fee
  class MiscFeePresenter < Fee::BaseFeePresenter
    def quantity
      return not_applicable_html unless agfs?
      return not_applicable_html if fee_type&.unique_code == 'MISTE'

      super
    end

    def rate
      return not_applicable_html unless agfs?
      return not_applicable_html if fee_type&.unique_code == 'MISTE'

      super
    end

    private

    def agfs? = fee&.claim&.agfs?
  end
end
