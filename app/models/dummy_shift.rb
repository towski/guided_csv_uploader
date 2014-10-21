class DummyShift < ActiveRecord::Base
  validate :max_3_per_day_per_user
    
  def max_3_per_day_per_user
    if DummyShift.where(:dummy_employee_id => dummy_employee_id, :wday => wday).count >= 3
      errors[:wday] = "only 3 shifts per user per day allowed"
      return false
    end
  end
end
