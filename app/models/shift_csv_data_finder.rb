FINDER_DATA_TYPES = [:employee_name, :clocked_in_date, :clocked_in_time, :clocked_in_datetime, :clocked_out_date, :clocked_out_time, :clocked_out_datetime].map!(&:to_s)
class ShiftCsvDataFinder < ActiveRecord::Base
  belongs_to :shift_csv

  validates_presence_of :column_number
  validates_presence_of :shift_csv
  validates_presence_of :data_type
  validates_presence_of :starting_row
  validates_inclusion_of :data_type, :in => FINDER_DATA_TYPES
end
