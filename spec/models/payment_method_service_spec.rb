require 'rails_helper'

RSpec.describe PaymentMethodService, type: :model do
  let(:method_object_map) do
    {
      free: PaymentMethodService::Free,
      credit_card: PaymentMethodService::CreditCard,
      pay_pig: PaymentMethodService::PayPig,
      atm: PaymentMethodService::Atm,
    }
  end

  describe "#gen" do
    it "should create a payment method service object with given method" do
      method_object_map.each do |key, klass|
        expect(PaymentMethodService.gen(key)).to be_a(klass)
      end
    end

    it "should raise an error if given an invalid method" do
      invalid_method = 'invalid_method'
      expect { PaymentMethodService.gen(invalid_method) }.to raise_error(/Invalid payment method/)
    end
  end

  describe "#run_paying" do
    it "should call run_paying with given method" do
      order_number = RandomToken.gen(14, s: :n)
      total_pay = Faker::Number.number(3).to_i
      method_object_map.each do |key, klass|
        pms = klass.new
        allow(PaymentMethodService).to receive(:gen).and_return(pms)
        expect(pms).to receive(:run_paying)
        PaymentMethodService.run_paying(key, order_number, total_pay)
      end
    end
  end
end
