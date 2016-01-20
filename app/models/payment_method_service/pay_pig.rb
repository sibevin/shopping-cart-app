module PaymentMethodService
  class PayPig < Base
    def get_expiration
      1.day.since
    end

    def run_paying(order_number, total_pay)
      service_result = PayPigService.pay(order_number: order_number, total_pay: total_pay)
      return case service_result[:error_code]
      when 0 then { redirect: :pay_pig_succ, status: :succ }
      else
        { redirect: :pay_pig_failed, msg: service_result[:msg], status: :failed }
      end
    end
  end
end
