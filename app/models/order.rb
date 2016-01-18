class Order < ActiveRecord::Base
  include Uidable
  uidable uid_name: :order_number

  belongs_to :user

  private

  def gen_order_number
    "#{self.created_at.strftime('%Y%m%d')}#{RandomToken.gen(6, s: :n)}"
  end
end
