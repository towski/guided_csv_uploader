require 'test_helper'

class ShiftCsvsControllerTest < ActionController::TestCase
  def test_success_redirect
    csv = fixture_file_upload 'example.csv'
    post :create, :data_finders => [{:column_number => 2, :starting_row => 2, :data_type => "employee_name"},
      {:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date"},
      {:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time"},
      {:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date"},
      {:column_number => 7, :starting_row => 2, :data_type => "clocked_out_time"}],
      :shift_csv => {:csv => csv, :multiple_employees => true}
    assert_response :redirect
  end

  def test_failure_show_template
    csv = fixture_file_upload 'example.csv'
    post :create, :data_finders => [{:column_number => 2, :starting_row => 2, :data_type => "employee_name"},
      {:column_number => 4, :starting_row => 2, :data_type => "clocked_in_date"},
      {:column_number => 5, :starting_row => 2, :data_type => "clocked_in_time"},
      {:column_number => 6, :starting_row => 2, :data_type => "clocked_out_date"}],
      :shift_csv => {:csv => csv}
    assert_response 200
  end

  def test_confirm
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example_one_employee.csv"), :multiple_employees => false, :employee_name => "Carlo"
    shift.data_finders.build(:column_number => 0, :starting_row => 8, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 1, :starting_row => 8, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 2, :starting_row => 8, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 3, :starting_row => 8, :data_type => "clocked_out_time")
    shift.save!
    get :confirm, :id => shift.id
    assert_response 200
  end

  def test_confirm_no_schedules
    shift = ShiftCsv.new :csv => File.new("test/fixtures/example_one_employee.csv"), :multiple_employees => false, :employee_name => "Carlo"
    shift.data_finders.build(:column_number => 0, :starting_row => 8, :data_type => "clocked_in_date")
    shift.data_finders.build(:column_number => 3, :starting_row => 8, :data_type => "clocked_in_time")
    shift.data_finders.build(:column_number => 2, :starting_row => 8, :data_type => "clocked_out_date")
    shift.data_finders.build(:column_number => 5, :starting_row => 8, :data_type => "clocked_out_time")
    shift.save!
    get :confirm, :id => shift.id
    assert_response 302
    debugger
    assert flash[:message].match(/shift/)
  end
end
