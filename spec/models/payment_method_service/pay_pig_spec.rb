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

  xdescribe "#run_paying" do
  end
end
