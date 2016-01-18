module PaymentMethodService
  class Free
    def get_expiration
      nil
    end

    def run_paying
      raise "You should implement 'run_paying' in your PaymentMethodService-based class"
    end
  end
end
