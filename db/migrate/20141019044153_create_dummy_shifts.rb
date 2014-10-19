class CreateDummyShifts < ActiveRecord::Migration
  def change
    create_table :dummy_shifts do |t|
      t.integer :dummy_employee_id
      t.integer :clocked_in_time
      t.datetime :clocked_in_at
      t.integer :clocked_out_time
      t.datetime :clocked_out_at
      t.integer :wday
      t.timestamps
    end

    reversible do |rev|
      rev.up do
        add_index :dummy_shifts, :wday
      end
      rev.down do
        remove_index :dummy_shifts, :wday
      end
    end
  end
end
