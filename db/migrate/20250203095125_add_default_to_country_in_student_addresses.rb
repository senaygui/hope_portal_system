class AddDefaultToCountryInStudentAddresses < ActiveRecord::Migration[7.0]
  def change
    change_column_default :student_addresses, :country, "Ethiopia"
  end
end
