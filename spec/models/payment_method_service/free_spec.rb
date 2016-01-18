require 'rails_helper'

RSpec.describe PaymentMethodService::Free, type: :model do
  let(:pms) { PaymentMethodService::Free.new }

  describe "#get_expiration" do
    it "should return nil" do
      expect(pms.get_expiration).to be_nil
    end
  end

  xdescribe "#run_paying" do
  end
end
