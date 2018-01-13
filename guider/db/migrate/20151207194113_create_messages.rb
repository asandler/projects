class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :booking_id, index: true
      t.integer :user_id
      t.text :message
      t.timestamps null: false
    end
  end
end
