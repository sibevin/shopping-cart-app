require 'rails_helper'

RSpec.describe PaymentMethodService::PayPig, type: :model do
  let(:pms) { PaymentMethodService::PayPig.new }

  describe "#get_expiration" do
    it "should return 1 day expiration" do
      time_now = Time.now
      travel_to(time_now) do
        expect(pms.get_expiration.to_s(:db)).to eq(1.day.since.to_s(:db))
      end
    end
  end

  describe "#run_paying" do
    let(:order_number) { "20160101#{RandomToken.gen(6, s: :n)}" }
    let(:total_pay) { Faker::Number.number(3).to_i }

    it "redirect to success page if PayPigService.pay error code == 0" do
      allow(PayPigService).to receive(:pay) { { error_code: 0 } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:pay_pig_succ)
    end

    it "redirect to error page if PayPigService.pay error code is not 0" do
      error_msg = Faker::Lorem.sentence(3)
      allow(PayPigService).to receive(:pay) { { error_code: rand(9) + 1, msg: error_msg } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:pay_pig_failed)
      expect(pms.run_paying(order_number, total_pay)[:msg]).to eq(error_msg)
    end
  end
end
