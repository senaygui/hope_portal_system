ActiveAdmin.register AddCourse do
  menu parent: 'Add-ons', label: 'Course Adds'

  permit_params :student_id, :course_id, :department_id, :year, :semester, :status, :section_id, :credit_hour, :ects

  filter :student
  filter :department_id, as: :search_select_filter, url: proc { admin_departments_path },
                         fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                         order_by: 'id_asc'

  filter :course_id, as: :search_select_filter, url: proc { admin_courses_path },
                     fields: %i[course_title id], display_name: 'course_title', minimum_input_length: 2,
                     order_by: 'id_asc'
  filter :year
  filter :semester
  batch_action :approve, confirm: 'Are you sure?' do |ids|
    add_courses = AddCourse.where(id: ids, status: 0)
    drop_ids = add_courses.where.not(dropcourse_id: nil).select(:dropcourse_id)
    drop_courses = Dropcourse.where(id: drop_ids)
    drop_courses.update(status: 2) if drop_courses.any?
    if add_courses.update(status: 1,  approved_by: current_admin_user.name.full)
      redirect_to admin_add_courses_path, notice: "#{ids.size} #{'course'.pluralize(ids.size)} approved for add"
    else
      redirect_to admin_add_courses_path, alert: 'Something went wrong. please check again'
    end
  end

  batch_action :rejecte, confirm: 'Are you sure?' do |ids|
    add_courses = AddCourse.where(id: ids, status: 0)
    drop_ids = add_courses.where.not(dropcourse_id: nil).select(:dropcourse_id)
    drop_courses = Dropcourse.where(id: drop_ids)

    if add_courses.update(status: 'pending', approved_by: current_admin_user.name.full)
      drop_courses.update(status: 1) if drop_courses.any?
      redirect_to admin_add_courses_path, notice: "#{ids.size} #{'course'.pluralize(ids.size)} pending for add"
    else
      redirect_to admin_add_courses_path, alert: 'Something went wrong. please check again'
    end
  end
  index do
    selectable_column
    column 'Student Name', sortable: true do |c|
      c.student.name.full
    end
    column 'Student Email' do |c|
      c.student.email
    end
    column 'Student Department', sortable: true do |c|
      c.student.department.department_name
    end
    column 'Student Year', sortable: true do |c|
      c.student.year
    end
    column 'Student Semester', sortable: true do |c|
      c.student.semester
    end
    column 'Student ID' do |c|
      c.student.student_id
    end
    column 'Course Title', sortable: true do |c|
      c.course.course_title
    end
    column 'Requested Course Code' do |c|
      c.course.course_code
    end
    column 'Requested Course Credit Hour' do |c|
      c.course.credit_hour
    end
    column 'Department to', sortable: true do |c|
      c.department.department_name
    end
    column 'Section', sortable: true do |c|
      c.section&.section_full_name
    end
    column 'Semester to' do |c|
      c.semester
    end
    column 'Year to' do |c|
      c.year
    end
    column 'Status' do |c|
      if c.pending?
        status_tag c.status
      elsif c.approved?
        status_tag c.status
      elsif c.rejected?
        status_tag c.status
      end
    end
    actions
  end

  show title: proc { |add_course| "Add Course Request For #{add_course.course.course_title}" } do
    columns do
      column do
        panel 'Student Information' do
          attributes_table_for add_course.student do
            row('Student Name') { |s| s.name.full }
            row('Student Email') { |s| s.email }
            row('Student ID') { |s| s.student_id }
            row('Department') { |s| s.department.department_name }
            row('Year') { |s| s.year }
            row('Semester') { |s| s.semester }
          end
        end
      end
      column do
        panel 'Requested Course Information' do
          attributes_table_for add_course.course do
            row('Course Title') { |c| c.course_title }
            row('Course Code') { |c| c.course_code }
            row('Credit Hour') { |c| c.credit_hour }
          end
          attributes_table_for add_course do
            row('Department to') { |c| c.department.department_name }
            row('Section') { |c| c.section&.section_full_name }
            row('Semester to') { |c| c.semester }
            row('Year to') { |c| c.year }
            row('Status') { |c| status_tag c.status }
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Student Information' do
      f.input :student_id, as: :search_select, url: admin_students_path,
                           fields: %i[student_id first_name last_name], display_name: 'student_id', minimum_input_length: 2,
                           order_by: 'id_asc', label: 'Student', input_html: { disabled: true }
      f.input :department_id, as: :search_select, url: admin_departments_path,
                              fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                              order_by: 'id_asc', label: 'Department', input_html: { disabled: true }
      f.input :section_id, as: :search_select, url: admin_sections_path,
                           fields: %i[section_full_name id], display_name: 'section_full_name', minimum_input_length: 2,
                           order_by: 'id_asc', label: 'Section', input_html: { allow_blank: true, disabled: true }
    end
    f.inputs 'Requested Course Information' do
      f.input :course_id, as: :search_select, url: admin_courses_path,
                          fields: %i[course_title course_code id], display_name: 'course_title', minimum_input_length: 2,
                          order_by: 'id_asc', label: 'Course', input_html: { disabled: true }
      f.input :credit_hour, input_html: { disabled: true }
      f.input :ects, input_html: { disabled: true }
      f.input :year, input_html: { disabled: true }
      f.input :semester, input_html: { disabled: true }
      f.input :status, as: :select, collection: AddCourse.statuses.keys, include_blank: false
    end
    f.actions
  end
end
