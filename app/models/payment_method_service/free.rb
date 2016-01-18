module PaymentMethodService
  class Free
    def get_expiration
      nil
    end

    def run_paying
      { redirect: :succ }
    end
  end
end
