require 'rails_helper'

RSpec.describe PaymentMethodService::Atm, type: :model do
  let(:pms) { PaymentMethodService::Atm.new }

  describe "#get_expiration" do
    it "should return 7 days expiration" do
      time_now = Time.now
      travel_to(time_now) do
        expect(pms.get_expiration.to_s(:db)).to eq(7.days.since.to_s(:db))
      end
    end
  end

  describe "#run_paying" do
    let(:order_number) { "20160101#{RandomToken.gen(6, s: :n)}" }
    let(:total_pay) { Faker::Number.number(3).to_i }

    it "redirect to success page if AtmService.pay error code == 0" do
      atm_account = RandomToken.gen(10, s: :n)
      allow(AtmService).to receive(:pay) { { error_code: 0, atm_account: atm_account } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:atm_succ)
      expect(pms.run_paying(order_number, total_pay)[:atm_account]).to eq(atm_account)
      expect(pms.run_paying(order_number, total_pay)[:status]).to eq(:succ)
    end

    it "redirect to error page if AtmService.pay error code is not 0" do
      allow(AtmService).to receive(:pay) { { error_code: rand(9) + 1 } }
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:atm_failed)
      expect(pms.run_paying(order_number, total_pay)[:status]).to eq(:failed)
    end
  end
end
