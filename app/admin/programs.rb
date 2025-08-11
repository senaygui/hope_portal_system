ActiveAdmin.register Program do
  menu parent: 'Program', label: 'Program Modality'
  permit_params :entrance_exam_requirement_status, :program_semester, :department_id, :total_semester, :program_name,
                :program_code, :overview, :program_description, :created_by, :last_updated_by, :total_tuition, :study_level, :admission_type, :program_duration, curriculums_attributes: %i[id curriculum_title curriculum_version total_course total_ects total_credit_hour batch active_status curriculum_active_date depreciation_date created_by last_updated_by _destroy]
  active_admin_import

  index do
    selectable_column
    column :program_name
    # column "Department", sortable: true do |d|
    #  # link_to d.department&.department_name, [:admin, d.department]
    # end
    column 'courses' do |c|
      c.courses.count
    end
    column :study_level
    column :admission_type
    column 'program year', :program_duration
    column :entrance_exam_requirement_status
    column 'Created At', :program_created_at do |c|
      c.created_at.strftime('%b %d, %Y')
    end
    actions
  end

  filter :program_name
  filter :department_id, as: :search_select_filter, url: proc { admin_departments_path },
                         fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                         order_by: 'id_asc'
  filter :study_level, as: :select, collection: %w[undergraduate graduate]
  filter :admission_type, as: :select, collection: %w[online regular extention distance]
  filter :program_duration, as: :select, collection: [1, 2, 3, 4, 5, 6, 7]
  filter :program_semester
  filter :entrance_exam_requirement_status, as: :select
  # filter :total_semester
  filter :created_by
  filter :last_updated_by
  filter :created_at
  filter :updated_at

  scope :recently_added
  scope :undergraduate
  scope :graduate
  scope :online, if: proc { current_admin_user.role == 'admin' }
  scope :regular, if: proc { current_admin_user.role == 'admin' }
  scope :extention, if: proc { current_admin_user.role == 'admin' }
  scope :distance, if: proc { current_admin_user.role == 'admin' }

  # controller do
  #  def scoped_collection
  #    super.my_faculty(current_admin_user).select("programs.*, programs.created_at AS program_created_at")
  #  end
  # end

  form do |f|
    f.semantic_errors
    f.inputs 'porgram information' do
      f.input :program_name
      f.input :program_code
      f.input :overview, input_html: { class: 'autogrow', rows: 10, cols: 20 }
      f.input :program_description, input_html: { class: 'autogrow', rows: 10, cols: 20 }
      f.input :department_id, as: :search_select, url: admin_departments_path,
                              fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                              order_by: 'id_asc'
      f.input :study_level, as: :select, collection: %w[undergraduate graduate TVET], include_blank: false
      f.input :admission_type, as: :select, collection: %w[online regular extention distance],
                               include_blank: false
      f.input :program_duration, as: :select, collection: [1, 2, 3, 4, 5, 6, 7], include_blank: false,
                                 label: 'program year'
      f.input :program_semester, as: :select, collection: [1, 2, 3, 4], include_blank: false
      # f.input :monthly_price
      # f.input :full_semester_price
      # f.input :two_monthly_price
      # f.input :three_monthly_price
      # f.input :total_semester
      f.input :entrance_exam_requirement_status
      if f.object.new_record?
        f.input :created_by, as: :hidden, input_html: { value: current_admin_user.name.full }
      else
        f.input :last_updated_by, as: :hidden, input_html: { value: current_admin_user.name.full }
      end
    end
    f.object.curriculums << Curriculum.new if f.object.curriculums.empty?
    panel 'Curriculum' do
      f.has_many :curriculums, heading: ' ', remote: true, allow_destroy: true, new_record: true do |a|
          a.input :curriculum_title
          a.input :curriculum_version
          a.input :batch, as: :select, collection: [
                '2019/2020',
                '2020/2021',
                '2021/2022',
                '2022/2023',
                '2023/2024',
                '2024/2025',
                '2025/2026',
                '2026/2027',
                '2027/2028',
                '2028/2029',
                '2029/2030'
              ], include_blank: false
          a.input :total_course
          a.input :total_ects
          a.input :total_credit_hour
          a.input :curriculum_active_date, as: :date_time_picker
          # a.input :course_id, as: :search_select, url: admin_courses_path,
          #   fields: [:course_title, :id], display_name: 'course_title', minimum_input_length: 2,
          #   order_by: 'id_asc'
          # a.input :credit_hour, :required => true, min: 1, as: :select, :collection => [1, 2,3,4,5,6,7], :include_blank => false
          # a.input :year, as: :select, :collection => [1, 2,3,4,5,6,7], :include_blank => false
          # a.input :semester, as: :select, :collection => [1, 2,3,4], :include_blank => false
          # a.input :course_starting_date, as: :date_time_picker
          # a.input :course_ending_date, as: :date_time_picker
          # a.input :full_course_price
          # a.input :monthly_course_price

          if a.object.new_record?
            a.input :created_by, as: :hidden, input_html: { value: current_admin_user.name.full }
          else
            a.input :active_status, as: :select, collection: %w[active depreciated]
            a.input :depreciation_date, as: :date_time_picker
            a.input :last_updated_by, as: :hidden, input_html: { value: current_admin_user.name.full }
          end
          a.label :_destroy
      end
    end
    f.actions
  end

  show title: :program_name do
    tabs do
      tab 'Program information' do
        panel 'Program information' do
          attributes_table_for program do
            row :program_name
            row :program_code
            row :overview
            row :program_description
            row 'Department', sortable: true do |d|
              link_to d.department&.department_name, [:admin, d.department]
            end
            row :study_level
            row :admission_type
            row :program_duration, label: 'program year'
            row :program_semester
            number_row 'Tuition', :total_tuition, as: :currency, unit: 'ETB', format: '%n %u', delimiter: ',',
                                                  precision: 2
            row :entrance_exam_requirement_status
            row :created_by
            row :last_updated_by
            row 'Created At', :program_created_at
            row :updated_at
          end
        end
      end
      tab 'Program curriculums' do
        panel 'curriculums list' do
          table_for program.curriculums.order('created_at ASC') do
              ## TODO: wordwrap titles and long texts
              column 'curriculum title' do |item|
                link_to item.curriculum_title, admin_curriculum_path(item)
              end
              column 'curriculum version' do |item|
                item.curriculum_version
              end
              column :batch
              column 'total course' do |item|
                item.total_course
              end
              column 'total Cr. Hrs' do |item|
                item.total_credit_hour
              end
              column 'Total ECTS' do |item|
                item.total_ects
              end
              column :active_status do |s|
                status_tag s.active_status
              end
              column :curriculum_active_date do |s|
                s.curriculum_active_date.strftime('%b %d, %Y')
              end
              column 'depreciated' do |s|
                s.depreciation_date.strftime('%b %d, %Y') if s.depreciation_date.present?
              end
              column 'Add', sortable: true do |c|
                c.created_at.strftime('%b %d, %Y')
              end
              column 'links', sortable: true do |c|
                "#{link_to('view',
                           admin_curriculum_path(c))} #{link_to 'edit', edit_admin_curriculum_path(c)}".html_safe
              end
              # column :created_by
              # column :last_updated_by
          end
        end
      end
      tab 'Course Breakdown' do
        panel 'Course Breakdown list' do
          (1..program.program_duration).map do |i|
            panel "ClassYear: Year #{i}" do
              (1..program.program_semester).map do |s|
                panel "Semester: #{s}" do
                  if program.curriculums.present? && program.courses.present?
                    table_for program.curriculums.where(active_status: 'active').first.courses.where(year: i, semester: s).order(
                      'year ASC', 'semester ASC'
                    ) do
                      ## TODO: wordwrap titles and long texts
                      column 'course title' do |item|
                        link_to item.course_title, [:admin, item]
                      end
                      column 'module code' do |item|
                        item.course_module.module_code
                      end
                      column 'course code' do |item|
                        item.course_code
                      end
                      column 'credit hour' do |item|
                        item.credit_hour
                      end
                      column :lecture_hour do |item|
                        item.lecture_hour
                      end
                      column :lab_hour do |item|
                        item.lab_hour
                      end
                      column 'contact hr.' do |item|
                        item.ects
                      end
                      column :created_by
                      column :last_updated_by
                      column 'Starts at', sortable: true do |c|
                        c.course_starting_date.strftime('%b %d, %Y') if c.course_starting_date.present?
                      end
                      column 'ends At', sortable: true do |c|
                        c.course_ending_date.strftime('%b %d, %Y') if c.course_ending_date.present?
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
