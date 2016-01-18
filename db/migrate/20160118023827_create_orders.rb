class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :user, index: true, foreign_key: true
      t.string :order_number, null: false
      t.string :state, limit: 20, null: false, default: 'shopping'
      t.string :payment_method, limit: 20
      t.string :failure_reason
      t.decimal :total_price, precision: 15, scale: 5
      t.decimal :total_point, precision: 15, scale: 5
      t.decimal :total_pay, precision: 15, scale: 5
      t.datetime :expired_at
      t.datetime :created_at, null: false
      t.datetime :cancelled_at
      t.datetime :paying_at
      t.datetime :paid_at
      t.datetime :failed_at
      t.datetime :repaid_at
    end
  end
end
