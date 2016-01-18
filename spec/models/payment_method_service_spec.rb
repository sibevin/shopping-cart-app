require 'rails_helper'

RSpec.describe PaymentMethodService, type: :model do
  describe "#gen" do
    it "should create a payment method service object with given method" do
      METHOD_OBJECT_MAP = {
        free: PaymentMethodService::Free,
        credit_card: PaymentMethodService::CreditCard,
        pay_pig: PaymentMethodService::PayPig,
        atm: PaymentMethodService::Atm,
      }
      METHOD_OBJECT_MAP.each do |key, klass|
        expect(PaymentMethodService.gen(key)).to be_a(klass)
      end
    end

    it "should raise an error if given an invalid method" do
      invalid_method = 'invalid_method'
      expect { PaymentMethodService.gen(invalid_method) }.to raise_error(/Invalid payment method/)
    end
  end
end
