module PaymentMethodService
  def self.gen(method)
    case method.to_sym
    when :free then PaymentMethodService::Free.new
    when :credit_card then PaymentMethodService::CreditCard.new
    when :pay_pig then PaymentMethodService::PayPig.new
    when :atm then PaymentMethodService::Atm.new
    else
      raise "Invalid payment method '#{method}'"
    end
  end

  def self.run_paying(method, order_number, total_pay)
    pms = PaymentMethodService.gen(method)
    pms.run_paying(order_number, total_pay)
  end
end
