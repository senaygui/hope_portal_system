class AddCreatedByAndLastUpdatedByToNotices < ActiveRecord::Migration[6.0]
  def change
    add_column :notices, :created_by, :string
    add_column :notices, :last_updated_by, :string
  end
end
