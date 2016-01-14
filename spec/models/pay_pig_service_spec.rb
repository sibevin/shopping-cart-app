require 'rails_helper'

RSpec.describe PayPigService, type: :model do
  describe "#pay" do
    let(:price) { Faker::Number.number(5).to_i }

    it "should return 0 error_code if the given order_number's last digit <= 6" do
      order_number = Faker::Number.number(10) + "#{Faker::Number.between(0, 6)}"
      expect(PayPigService.pay(order_number: order_number, total_pay: price)[:error_code]).to eql(0)
    end

    it "should return an error_code between 1 to 9 and an random msg if the given order_number's last digit >= 7" do
      order_number = Faker::Number.number(10) + "#{Faker::Number.between(7, 9)}"
      expect(PayPigService.pay(order_number: order_number, total_pay: price)[:error_code]).to be_between(1, 9)
      expect(PayPigService.pay(order_number: order_number, total_pay: price)[:msg]).not_to be_empty
    end
  end
end
