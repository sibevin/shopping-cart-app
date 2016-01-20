module PaymentMethodService
  class CreditCard < Base
    def get_expiration
      2.hours.since
    end

    def run_paying(order_number, total_pay)
      service_result = CreditCardService.pay(order_number: order_number, total_pay: total_pay)
      return case service_result[:error_code]
      when 0 then { redirect: :credit_card_succ }
      when 1 then { redirect: :credit_card_pending }
      else
        { redirect: :credit_card_failed, msg: service_result[:msg] }
      end
    end
  end
end
