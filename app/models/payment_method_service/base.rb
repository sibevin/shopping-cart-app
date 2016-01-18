module PaymentMethodService
  class Base
    def get_expiration
      raise "You should implement 'get_expiration' in your PaymentMethodService-based class"
    end

    def run_paying
      raise "You should implement 'run_paying' in your PaymentMethodService-based class"
    end
  end
end
