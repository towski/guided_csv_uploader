class CreateDummyEmployees < ActiveRecord::Migration
  def change
    create_table :dummy_employees do |t|
      t.integer :shift_csv_id
      t.string :identifier
      t.timestamps
    end
    reversible do |dir|
      dir.up do
        add_index :dummy_employees, :identifier, :unique => true
      end
      dir.down do
        if index_exists? :dummy_employees, :identifier
          remove_index :dummy_employees, :identifier
        end
      end
    end
  end
end
