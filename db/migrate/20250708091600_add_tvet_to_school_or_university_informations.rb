class AddTvetToSchoolOrUniversityInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :school_or_university_informations, :tvet_program_attend, :string
    add_column :school_or_university_informations, :coc_attended_date, :datetime
    add_column :school_or_university_informations, :coc_id, :string
    add_column :school_or_university_informations, :tvet_level, :string
  end
end
