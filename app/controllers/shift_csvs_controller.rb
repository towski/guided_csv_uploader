class ShiftCsvsController < ApplicationController
  before_filter :check_for_data_finders_params, :only => :create

  def index
    redirect_to new_shift_csv_url
  end

  def new
    @shift = ShiftCsv.new 
  end

  def create
    @shift = ShiftCsv.new shift_csv_params
    params[:data_finders].each do |data_finder_hash|
      finder = @shift.data_finders.build data_finder_hash.permit(:column_number, :starting_row, :data_type)
    end
    if @shift.save
      redirect_to confirm_shift_csv_path(@shift)
    else
      render :new
    end
  end

  def confirm
    @shift = ShiftCsv.find params[:id] 
  end

  protected

  def check_for_data_finders_params
    unless params[:data_finders]
      flash[:message] = "Not enough columns selected"
      redirect_to new_shift_csvs_path
    end
  end

  def shift_csv_params
    params[:shift_csv].permit(:csv, :employee_name, :multiple_employees)
  end
end
