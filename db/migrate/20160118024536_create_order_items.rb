class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      t.decimal :unit_price, precision: 15, scale: 5
      t.integer :count, null: false, default: 1
      t.string :name
      t.text :description
    end
  end
end
