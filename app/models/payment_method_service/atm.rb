module PaymentMethodService
  class Atm < Base
    def get_expiration
      7.days.since
    end

    def run_paying(order_number, total_pay)
      service_result = AtmService.pay(order_number: order_number, total_pay: total_pay)
      return case service_result[:error_code]
      when 0 then { redirect: :atm_succ, atm_account: service_result[:atm_account], status: :succ }
      else
        { redirect: :atm_failed, msg: service_result[:msg], status: :failed }
      end
    end
  end
end
