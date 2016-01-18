module PaymentMethodService
  class CreditCard
    def get_expiration
      2.hours.since
    end

    def run_paying
      raise "You should implement 'run_paying' in your PaymentMethodService-based class"
    end
  end
end
