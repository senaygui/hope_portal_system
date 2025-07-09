class AddInstructorFieldsToAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_users, :type_of_employment, :string
    add_column :admin_users, :gender, :string
    add_column :admin_users, :highest_level_educational_achievement, :string
  end
end
