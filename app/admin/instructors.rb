ActiveAdmin.register AdminUser, as: 'instructor' do
  menu parent: 'Department'
  permit_params :photo, :email, :password, :password_confirmation, :first_name, :last_name, :middle_name, :role,
                :username, :type_of_employment, :gender, :highest_level_educational_achievement, :department_id

  controller do
    def scoped_collection
      super.where(role: 'instructor')
    end
  end

  index do
    selectable_column
    column 'Full Name', sortable: true do |n|
      n.name.full
    end
    column :email
    column :role
    column :department do |instructor|
      instructor.department&.department_name
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :middle_name
  filter :email
  filter :type_of_employment
  filter :gender
  filter :highest_level_educational_achievement
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :department_id, as: :search_select_filter, url: proc { admin_departments_path },
                         fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                         order_by: 'id_asc'

  form do |f|
    f.inputs 'Instructor Account' do
      f.input :first_name
      f.input :last_name
      f.input :middle_name
      f.input :username
      f.input :email
      if !f.object.new_record?
        f.input :current_password
      else
        f.input :role, as: :hidden, input_html: { value: 'instructor' }
      end
      f.input :password
      f.input :password_confirmation
      f.input :photo, as: :file
      f.input :type_of_employment, as: :select, collection: %w[Part-time Full-time], include_blank: false
      f.input :gender, as: :select, collection: %w[Male Female], include_blank: false
      f.input :highest_level_educational_achievement, as: :select, collection: [
        'Degree',
        'Masters',
        'PhD Candidate',
        'PhD Holder (Doctor)',
        'Assistant Professor',
        'Associate Professor',
        'Professor'
      ], include_blank: false
      f.input :department, as: :select, collection: Department.all.collect { |d|
                                                      [d.department_name, d.id]
                                                    }, include_blank: false
    end
    f.actions
  end

  show title: proc { |instructor| instructor.name.full } do
    panel 'Instructor Information' do
      attributes_table_for instructor do
        row 'photo' do |pt|
          span image_tag(pt.photo, size: '150x150', class: 'img-corner') if pt.photo.attached?
        end
        row :first_name
        row :last_name
        row :middle_name
        row :username
        row :email
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
        row :created_at
        row :updated_at
        row :type_of_employment
        row :gender
        row :highest_level_educational_achievement
        row :department do |instructor|
          instructor.department&.department_name
        end
      end
    end
  end

  action_item :course_assignments_report, only: :index do
    if current_admin_user.role == 'department head'
      link_to 'Instructor Load Report', course_assignments_report_path, class: 'button'
    end
  end
end
