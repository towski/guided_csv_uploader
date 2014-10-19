require 'csv'

class ShiftCsv < ActiveRecord::Base
  attr_accessor :dont_extract_data
  has_attached_file :csv 
  validates_attachment :csv, :presence => true, :size => { :in => 0..1000.kilobytes }
  do_not_validate_attachment_file_type :csv
  validates_size_of :data_finders, :minimum => 3

  has_many :data_finders, :class_name => "ShiftCsvDataFinder"
  has_many :dummy_employees

  after_save :extract_data

  def extract_data
    return true if dont_extract_data
    employee_name_finder = data_finders.where(:data_type => "employee_name").first
    clocked_in_date_finder = data_finders.where(:data_type => "clocked_in_date").first
    clocked_in_time_finder = data_finders.where(:data_type => "clocked_in_time").first
    clocked_out_date_finder = data_finders.where(:data_type => "clocked_out_date").first
    clocked_out_time_finder = data_finders.where(:data_type => "clocked_out_time").first
    CSV.open(csv.path, headers:false) do |guest|
      guests = guest.each
      row_number = 1
      guests.select do |row| 
        if employee_name_finder.starting_row < row_number
          name = row[employee_name_finder.column_number - 1]
          clocked_in_date = Chronic.parse(row[clocked_in_date_finder.column_number - 1])
          break if clocked_in_date.nil?
          clocked_in_date = clocked_in_date.to_date
          clocked_in_time = Chronic.parse(row[clocked_in_time_finder.column_number - 1]).seconds_since_midnight
          clocked_out_date = Chronic.parse(row[clocked_out_date_finder.column_number - 1])
          break if clocked_out_date.nil?
          clocked_out_date = clocked_out_date.to_date
          clocked_out_time = Chronic.parse(row[clocked_out_time_finder.column_number - 1]).seconds_since_midnight
          employee = dummy_employees.find_or_create_by :identifier => name
          seconds_away_from_interval = clocked_in_time % 900
          rounded_in_time = seconds_away_from_interval < 450 ? clocked_in_time - seconds_away_from_interval : clocked_in_time + seconds_away_from_interval
          seconds_away_from_interval = clocked_out_time % 900
          rounded_out_time = seconds_away_from_interval < 450 ? clocked_out_time - seconds_away_from_interval : clocked_out_time + seconds_away_from_interval
          next if rounded_in_time == rounded_out_time
          shift = employee.dummy_shifts.create!(
            :clocked_in_at => clocked_in_date.to_time + clocked_in_time, 
            :clocked_in_time => rounded_in_time,
            :clocked_out_at => clocked_out_date.to_time + clocked_out_time, 
            :clocked_out_time => rounded_out_time,
            :wday => clocked_in_date.wday
          )
        end
        row_number += 1
      end
    end
  end
end