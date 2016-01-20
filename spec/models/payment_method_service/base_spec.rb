require 'rails_helper'

RSpec.describe PaymentMethodService::Base, type: :model do
  let(:pms) { PaymentMethodService::Base.new }

  describe "#get_expiration" do
    it "should raise an error if 'get_expiration' is not implemented" do
      expect { pms.get_expiration }.to raise_error(/should implement/)
    end
  end

  describe "#run_paying" do
    let(:order_number) { "20160101#{RandomToken.gen(6, s: :n)}" }
    let(:total_pay) { Faker::Number.number(3).to_i }

    it "should raise an error if 'run_paying' is not implemented" do
      expect { pms.run_paying(order_number, total_pay) }.to raise_error(/should implement/)
    end
  end
end
