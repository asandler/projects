class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :route
      t.references :user
      t.text :date

      t.timestamps null: false
    end

    add_index :bookings, :route_id
  end
end
