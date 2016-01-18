class Order < ActiveRecord::Base
  include Uidable
  uidable uid_name: :order_number

  belongs_to :user

  def cancel
    if self.state == 'shopping'
      self.cancelled_at = Time.now
      self.state = 'cancelled'
    end
  end

  def pay
    if self.state == 'paying'
      self.paid_at = Time.now
      self.state = 'paid'
    end
  end

  private

  def gen_order_number
    "#{self.created_at.strftime('%Y%m%d')}#{RandomToken.gen(6, s: :n)}"
  end
end
