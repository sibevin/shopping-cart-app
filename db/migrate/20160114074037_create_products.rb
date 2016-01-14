class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :unit_price, precision: 15, scale: 5
      t.timestamps null: false
    end
  end
end
