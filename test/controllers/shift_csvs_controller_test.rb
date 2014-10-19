require 'test_helper'

class ShiftCsvsControllerTest < ActionController::TestCase
  def test_hey
    csv = fixture_file_upload 'example.csv'
    post :create, :data_finders => [{:column_number => 1, :starting_row => 2, :data_type => FINDER_DATA_TYPES[0]}, 
      {:column_number => 1, :starting_row => 2, :data_type => FINDER_DATA_TYPES[0]},
      {:column_number => 1, :starting_row => 2, :data_type => FINDER_DATA_TYPES[0]}],
      :shift_csv => {:csv => csv}
    assert_response :redirect
  end
end
