require 'rails_helper'

RSpec.describe PaymentMethodService::Base, type: :model do
  let(:pms) { PaymentMethodService::Base.new }

  describe "#get_expiration" do
    it "should raise an error if 'get_expiration' is not implemented" do
      expect { pms.get_expiration }.to raise_error(/should implement/)
    end
  end

  describe "#run_paying" do
    it "should raise an error if 'run_paying' is not implemented" do
      expect { pms.run_paying }.to raise_error(/should implement/)
    end
  end
end
