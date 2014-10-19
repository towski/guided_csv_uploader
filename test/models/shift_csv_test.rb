require 'test_helper'

class ShiftCsvTest < ActiveSupport::TestCase
  def test_csv
    shift = ShiftCsv.new
    shift.valid?
    assert shift.errors[:csv]
    assert shift.errors[:data_finders]
  end

  def test_with_file
    shift = ShiftCsv.new
    shift.csv = File.new("test/fixtures/example.csv")
    shift.data_finders.build(:column_number => 2, :starting_row => 2, :data_type => "employee_name")
    shift.data_finders.build(:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 7, :starting_row => 2, :data_type => "clocked_out_time")
    shift.dont_extract_data = true
    assert shift.save
  end

  def test_make_data_finders_without_data
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example.csv")
    finder = shift.data_finders.build
    finder.shift_csv = nil
    finder.valid?
    assert !finder.errors[:column_number].blank?
    assert !finder.errors[:shift_csv].blank?
    assert !finder.errors[:data_type].blank?
    assert !finder.errors[:starting_row].blank?
  end

  def test_make_data_finders_without_data_type
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example.csv")
    shift.data_finders.build(:column_number => 2, :starting_row => 2, :data_type => "employee_name")
    shift.data_finders.build(:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 7, :starting_row => 2, :data_type => "clocked_out_time")
    shift.dont_extract_data = true
    shift.save!
    finder = shift.data_finders.build(:column_number => 1, :starting_row => 2, :data_type => "not_a_data_type")
    assert !finder.valid?
  end

  def test_data_finders
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example.csv")
    shift.data_finders.build(:column_number => 2, :starting_row => 2, :data_type => "employee_name")
    shift.data_finders.build(:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 7, :starting_row => 2, :data_type => "clocked_out_time")
    shift.dont_extract_data = true
    shift.save!
    finder = shift.data_finders.build(:column_number => 1, :starting_row => 2, :data_type => FINDER_DATA_TYPES[0])
    assert finder.valid?
  end

  def test_will_process_to_dummy_data
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example.csv")
    shift.data_finders.build(:column_number => 2, :starting_row => 2, :data_type => "employee_name")
    shift.data_finders.build(:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 7, :starting_row => 2, :data_type => "clocked_out_time")
    assert_difference "DummyShift.count", 43 do
      assert_difference "shift.dummy_employees.size", 12 do
        shift.save!
        shift.dummy_employees.each do |employee|
          assert !employee.identifier.blank?
          employee.dummy_shifts.each do |shift|
            assert shift.wday
            assert shift.clocked_in_at
            assert shift.dummy_employee_id
            assert shift.clocked_in_time
            assert shift.clocked_out_at
            assert shift.clocked_out_time
            assert_not_equal shift.clocked_in_at, shift.clocked_out_at
            assert_not_equal shift.clocked_in_time, shift.clocked_out_time
          end
        end
      end
    end
  end
end
