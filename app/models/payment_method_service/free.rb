module PaymentMethodService
  class Free < Base
    def get_expiration
      nil
    end

    def run_paying(order_number, total_pay)
      { redirect: :free_succ, status: :succ }
    end
  end
end
