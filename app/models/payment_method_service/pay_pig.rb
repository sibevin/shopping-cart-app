module PaymentMethodService
  class PayPig
    def get_expiration
      1.day.since
    end

    def run_paying
      raise "You should implement 'run_paying' in your PaymentMethodService-based class"
    end
  end
end
