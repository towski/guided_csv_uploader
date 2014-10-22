class DummyShift < ActiveRecord::Base
  validate :max_3_per_day_per_user
  validate :clocked_in_before_clocked_out

  def clocked_in_before_clocked_out
    if clocked_in_at > clocked_out_at 
      errors[:clocked_in_at] = "Clocked in date after clocked out date"
    end
    if clocked_in_time > clocked_out_time
      errors[:clocked_in_time] = "Clocked in time after clocked out date"
    end
  end
    
  def max_3_per_day_per_user
    if DummyShift.where(:dummy_employee_id => dummy_employee_id, :wday => wday).count >= 3
      errors[:wday] = "only 3 shifts per user per day allowed"
      return false
    end
  end
end
