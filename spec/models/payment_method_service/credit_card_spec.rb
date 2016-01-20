require 'rails_helper'

RSpec.describe PaymentMethodService::CreditCard, type: :model do
  let(:pms) { PaymentMethodService::CreditCard.new }

  describe "#get_expiration" do
    it "should return 2 hours expiration" do
      time_now = Time.now
      travel_to(time_now) do
        expect(pms.get_expiration.to_s(:db)).to eq(2.hours.since.to_s(:db))
      end
    end
  end

  describe "#run_paying" do
    let(:order_number) { "20160101#{RandomToken.gen(6, s: :n)}" }
    let(:total_pay) { Faker::Number.number(3).to_i }

    it "redirect to success page if CreditCardService.pay error code == 0" do
      allow(CreditCardService).to receive(:pay) { { error_code: 0 } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:credit_card_succ)
      expect(pms.run_paying(order_number, total_pay)[:status]).to eq(:succ)
    end

    it "redirect to error page if CreditCardService.pay error code == 1" do
      allow(CreditCardService).to receive(:pay) { { error_code: 1 } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:credit_card_pending)
      expect(pms.run_paying(order_number, total_pay)[:status]).to eq(:pending)
    end

    it "redirect to error page if PayPigService.pay error code > 1" do
      error_msg = Faker::Lorem.sentence(3)
      allow(CreditCardService).to receive(:pay) { { error_code: rand(8) + 2, msg: error_msg } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:credit_card_failed)
      expect(pms.run_paying(order_number, total_pay)[:msg]).to eq(error_msg)
      expect(pms.run_paying(order_number, total_pay)[:status]).to eq(:failed)
    end
  end
end
