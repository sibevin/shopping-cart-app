module PaymentMethodService
  class Atm
    def get_expiration
      7.days.since
    end

    def run_paying
      raise "You should implement 'run_paying' in your PaymentMethodService-based class"
    end
  end
end
