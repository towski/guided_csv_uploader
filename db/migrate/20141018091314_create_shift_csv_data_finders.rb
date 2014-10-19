class CreateShiftCsvDataFinders < ActiveRecord::Migration
  def change
    create_table :shift_csv_data_finders do |t|
      t.integer :column_number
      t.integer :starting_row
      t.string :data_type
      t.integer :shift_csv_id
      t.timestamps
    end
  end
end
