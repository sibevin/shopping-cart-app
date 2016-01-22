require 'rails_helper'

RSpec.describe PaymentMethodService::Free, type: :model do
  let(:pms) { PaymentMethodService::Free.new }

  describe "#get_expiration" do
    it "should return nil" do
      expect(pms.get_expiration).to be_nil
    end
  end

  describe "#run_paying" do
    let(:order_number) { RandomToken.gen(14, s: :n) }
    let(:total_pay) { Faker::Number.number(3).to_i }

    it "redirect to success page" do
      expect(pms.run_paying(order_number, total_pay)[:redirect]).to eq(:free_succ)
    end
  end
end
