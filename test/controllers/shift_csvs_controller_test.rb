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
end
