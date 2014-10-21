class CreateShiftCsvs < ActiveRecord::Migration
  def change
    create_table :shift_csvs do |t|
      t.boolean :multiple_employees
      t.string :employee_name
      t.timestamps
    end
  end
end
