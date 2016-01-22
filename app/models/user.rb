class User < ActiveRecord::Base
  has_many :orders

  def get_shopping_order
    if so = self.orders.where(state: 'shopping').take
      return so
    else
      return self.orders.create(state: 'shopping')
    end
  end
end
