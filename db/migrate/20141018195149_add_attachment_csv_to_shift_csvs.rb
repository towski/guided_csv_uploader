class AddAttachmentCsvToShiftCsvs < ActiveRecord::Migration
  def self.up
    change_table :shift_csvs do |t|
      t.attachment :csv
    end
  end

  def self.down
    remove_attachment :shift_csvs, :csv
  end
end
