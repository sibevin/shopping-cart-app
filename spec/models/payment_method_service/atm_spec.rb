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

  xdescribe "#run_paying" do
  end
end
