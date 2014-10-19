class ShiftCsvsController < ApplicationController
  def new
  end

  def create
    shift = ShiftCsv.new shift_csv_params
    params[:data_finders].each do |data_finder_hash|
      finder = shift.data_finders.build data_finder_hash.permit(:column_number, :starting_row, :data_type)
    end
    if shift.save
      redirect_to confirm_shift_csv_path(1)
    else
      render :new
    end
  end

  def confirm
  end

  protected
  def shift_csv_params
    params[:shift_csv].permit(:csv)
  end
end
