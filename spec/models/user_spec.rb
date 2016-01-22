require 'rails_helper'

RSpec.describe User, type: :model do
  describe ".get_shopping_order" do
    let(:user) { create(:user) }

    it "should return the current shopping order if it is existing" do
      order = create(:order, user: user, state: 'shopping')
      expect(user.get_shopping_order).to eq(order)
    end

    it "should create a new shopping order if there is no shopping order" do
      order = user.get_shopping_order
      shopping_orders = user.orders.where(state: 'shopping')
      expect(shopping_orders.size).to eq(1)
      expect(shopping_orders.take).to eq(order)
    end
  end
end
