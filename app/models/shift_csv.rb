require 'csv'

class ShiftCsv < ActiveRecord::Base
  attr_accessor :dont_extract_data
  has_attached_file :csv 
  validates_attachment :csv, :presence => true, :size => { :in => 0..1000.kilobytes }
  do_not_validate_attachment_file_type :csv
  validates_size_of :data_finders, :minimum => 3, :maximum => 8
  validates_presence_of :employee_name, :if => lambda { !multiple_employees }

  has_many :data_finders, :class_name => "ShiftCsvDataFinder"
  has_many :dummy_employees

  before_save :has_all_data_finders

  def has_all_data_finders
    ["clocked_in_date", "clocked_in_time", "clocked_out_date", "clocked_out_time"].each do |data_type|
      if data_finders.select{|d| d.data_type == data_type }.blank?
        errors[:data_finders] = "no #{data_type} for model"
      end
    end
    if multiple_employees && data_finders.select{|d| d.data_type == "employee_name" }.blank?
      errors[:data_finders] = "no employee row for model"
    end
  end

  def clocked_in_date_finder
    @clocked_in_date_finder ||= data_finders.where(:data_type => "clocked_in_date").first
  end

  def clocked_in_time_finder
    @clocked_in_time_finder ||= data_finders.where(:data_type => "clocked_in_time").first
  end

  def clocked_out_date_finder
    @clocked_out_date_finder ||= data_finders.where(:data_type => "clocked_out_date").first
  end

  def clocked_out_time_finder
    @clocked_out_time_finder ||= data_finders.where(:data_type => "clocked_out_time").first
  end

  def employee_name_finder
    @employee_name_finder ||= data_finders.where(:data_type => "employee_name").first
  end

  after_save :extract_data

  def extract_data
    return true if dont_extract_data
    employee = nil
    starting_row = nil
    if multiple_employees
      starting_row = employee_name_finder.starting_row
    else
      @employee = dummy_employees.find_or_create_by :identifier => employee_name
      starting_row = clocked_in_date_finder.starting_row
    end
    CSV.open(csv.path, headers:false) do |guest|
      guests = guest.each
      row_number = 1
      guests.select do |row| 
        if starting_row < row_number
          if row.compact.empty?
            row_number += 1
            next 
          end
          process_row(row)
        end
        row_number += 1
      end
    end
  end

  def process_row(row)
    clocked_in_date = Chronic.parse(row[clocked_in_date_finder.column_number])
    return if clocked_in_date.nil?
    clocked_in_date = clocked_in_date.to_date
    clocked_in_time = Chronic.parse(row[clocked_in_time_finder.column_number])
    return if  clocked_in_time.nil?
    clocked_in_time = clocked_in_time.seconds_since_midnight
    clocked_out_date = Chronic.parse(row[clocked_out_date_finder.column_number])
    return if clocked_out_date.nil?
    clocked_out_date = clocked_out_date.to_date
    clocked_out_time = Chronic.parse(row[clocked_out_time_finder.column_number])
    return if clocked_out_time.nil?
    clocked_out_time = clocked_out_time.seconds_since_midnight
    return if @first_date && clocked_in_date > @first_date + 7 
    if multiple_employees
      name = row[employee_name_finder.column_number]
      @employee = dummy_employees.find_or_create_by :identifier => name
    end
    seconds_away_from_interval = clocked_in_time % 900
    rounded_in_time = seconds_away_from_interval < 450 ? clocked_in_time - seconds_away_from_interval : clocked_in_time + (900 - seconds_away_from_interval)
    seconds_away_from_interval = clocked_out_time % 900
    rounded_out_time = seconds_away_from_interval < 450 ? clocked_out_time - seconds_away_from_interval : clocked_out_time + (900 - seconds_away_from_interval)
    # if the shift doesn't have any time
    return if rounded_in_time == rounded_out_time && clocked_out_date == clocked_in_date
    if !multiple_employees && @first_date.nil?
      @first_date = clocked_in_date
    end
    @employee.dummy_shifts.create(
      :clocked_in_at => clocked_in_date.to_time + clocked_in_time, 
      :clocked_in_time => rounded_in_time,
      :clocked_out_at => clocked_out_date.to_time + clocked_out_time, 
      :clocked_out_time => rounded_out_time,
      :wday => clocked_in_date.wday
    )
  end
end
