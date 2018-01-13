class AddFieldsToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :guide_id, :integer
    add_index :bookings, :guide_id
  end

end
