ActiveAdmin.register Curriculum do
menu parent: "Program",label: "CourseOffering-Curriculum"
 #permit_params :program_id,:curriculum_title,:curriculum_version,:total_course,:total_ects,:total_credit_hour,:active_status,:curriculum_active_date,:depreciation_date,:created_by,:last_updated_by, courses_attributes: [:id,:course_module_id,:program_id,:curriculum_id,:semester,:course_starting_date,:course_ending_date,:year,:credit_hour,:lecture_hour,:lab_hour,:ects,:course_code,:course_title,:created_by,:last_updated_by, :_destroy]
 permit_params :batch,:program_id, :curriculum_title, :curriculum_version, :total_course, :total_ects, 
              :total_credit_hour, :active_status, :curriculum_active_date, :depreciation_date, 
              :created_by, :last_updated_by, 
              courses_attributes: [:id, :course_module_id, :program_id, :curriculum_id, :semester, 
                                    :course_starting_date, :course_ending_date, :year, :credit_hour, 
                                    :lecture_hour, :lab_hour, :ects, :course_code, :course_title, 
                                    :created_by, :last_updated_by, :_destroy], 
              grade_systems_attributes: [:id, :min_cgpa_value_to_pass, :min_cgpa_value_to_graduate, 
                                        :remark, :study_level, :program_id, :curriculum_id, :_destroy, 
                                        grades_attributes: [:id, :letter_grade, :grade_point, :min_row_mark, 
                                                            :max_row_mark, :_destroy], 
                                        academic_statuses_attributes: [:id, :status, :min_value, 
                                                                       :max_value, :_destroy]]

 active_admin_import
 index do
  selectable_column
  column :curriculum_title
  column  "Version",:curriculum_version
  column :batch
  column "Program", sortable: true do |d|
    link_to d.program.program_name, [:admin, d.program]
  end
  column "Courses",:total_course
  column "Credit hours",:total_credit_hour
  column "ECTS",:total_ects
  column :active_status do |s|
    status_tag s.active_status
  end
  column "Add At", sortable: true do |c|
    c.created_at.strftime("%b %d, %Y")
  end
  actions
end

filter :program_id, as: :search_select_filter, url: proc { admin_programs_path },
fields: [:program_name, :id], display_name: 'program_name', minimum_input_length: 2,
order_by: 'id_asc'
filter :curriculum_title
filter :curriculum_version
filter :batch
filter :total_course

#filter :total_ects
filter :total_credit_hour
filter :active_status
filter :curriculum_active_date
filter :depreciation_date
filter :created_by
filter :last_updated_by

filter :created_at
filter :updated_at

# scope :recently_added

  #form do |f|
  #  f.semantic_errors
  #  if !(params[:page_name] == "add_course")
  #    f.inputs "Curriculum information" do
  #      f.input :program_id, as: :search_select, url: admin_programs_path,
  #      fields: [:program_name, :id], display_name: 'program_name', minimum_input_length: 2,
  #      order_by: 'id_asc'
  #      f.input :curriculum_title
  #      f.input :curriculum_version
  #      f.input :total_course
  #      f.input :total_ects
  #      f.input :total_credit_hour
  #      f.input :curriculum_active_date, as: :date_time_picker 
#
  #      if f.object.new_record?
  #        f.input :created_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
  #      else
  #        f.input :active_status, as: :select, :collection => ["active","depreciated"]
  #        f.input :depreciation_date, as: :date_time_picker
  #        f.input :last_updated_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
  #      end      
  #    end
  #  end
  #  
  #  if f.object.new_record? || (params[:page_name] == "add_course")
  #    if f.object.courses.empty?
  #      f.object.courses << Course.new
  #    end
  #    panel "Course Breakdown Information" do
  #      f.has_many :courses,heading: " ", remote: true, allow_destroy: true, new_record: true do |a|
  #        a.input :course_module_id, as: :search_select, url: admin_course_modules_path,
  #          fields: [:module_title, :id], display_name: 'module_title', minimum_input_length: 2,
  #          order_by: 'id_asc'
  #        a.input :course_title
  #        a.input :course_code
  #        a.input :credit_hour, :required => true, min: 1, as: :select, :collection => [0,1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], :include_blank => false
  #        a.input :lecture_hour
  #        a.input :lab_hour
  #        a.input :ects, label:"contact hr"
  #        a.input :course_description,  :input_html => { :class => 'autogrow', :rows => 5, :cols => 20}
  #        a.input :year, as: :select, :collection => [1, 2,3,4,5,6,7], :include_blank => false
  #        a.input :semester, as: :select, :collection => [1, 2,3,4], :include_blank => false
  #        a.input :course_starting_date, as: :date_time_picker 
  #        a.input :course_ending_date, as: :date_time_picker
#
  #        if a.object.new_record?
  #          a.input :created_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
  #        else
  #          a.input :last_updated_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
  #        end 
  #        a.label :_destroy
  #      end
  #    end
  #  end
  #  f.actions
  #end

  ActiveAdmin.register Curriculum do
    permit_params :batch, :program_id, :curriculum_title, :curriculum_version, :total_course, :total_ects, 
                  :total_credit_hour, :active_status, :curriculum_active_date, :depreciation_date, 
                  :created_by, :last_updated_by, 
                  courses_attributes: [:id, :course_module_id, :program_id, :curriculum_id, :semester, 
                                        :course_starting_date, :course_ending_date, :year, :credit_hour, 
                                        :lecture_hour, :lab_hour, :ects, :course_code, :course_title, :course_type,
                                        :created_by, :last_updated_by, :_destroy], 
                  grade_systems_attributes: [:id, :min_cgpa_value_to_pass, :min_cgpa_value_to_graduate, 
                                            :remark, :study_level, :program_id, :_destroy, 
                                            grades_attributes: [:id, :letter_grade, :grade_point, 
                                                                :min_row_mark, :max_row_mark, :_destroy], 
                                            academic_statuses_attributes: [:id, :status, :min_value, 
                                                                           :max_value, :_destroy]]
  
                                                                           controller do
                                                                            def create
                                                                              @curriculum = Curriculum.new(permitted_params[:curriculum])
                                                                          
                                                                              # Save the curriculum first
                                                                              if @curriculum.save
                                                                                # Ensure courses are saved with the curriculum_id
                                                                                @curriculum.courses.each do |course|
                                                                                  course.update(curriculum_id: @curriculum.id)
                                                                                end
                                                                          
                                                                                # Ensure grade systems are saved with the curriculum_id
                                                                                @curriculum.grade_systems.each do |grade_system|
                                                                                  grade_system.update(curriculum_id: @curriculum.id)
                                                                                end
                                                                          
                                                                                redirect_to admin_curriculum_path(@curriculum), notice: "Curriculum was successfully created."
                                                                              else
                                                                                render :new
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                          
  

  form do |f|
    f.semantic_errors
    
    # Curriculum Information
    f.inputs "Curriculum Information" do
      f.input :program_id, as: :search_select, url: admin_programs_path,
        fields: [:program_name, :id], display_name: 'program_name', minimum_input_length: 2,
        order_by: 'id_asc'
      f.input :curriculum_title
      f.input :curriculum_version
      f.input :batch, as: :select, collection: [
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
      f.input :total_course
      f.input :total_ects
      f.input :total_credit_hour
      f.input :curriculum_active_date, as: :date_time_picker
      f.input :created_by, as: :hidden, input_html: { value: current_admin_user.name.full } if f.object.new_record?
      f.input :active_status, as: :select, collection: ["active", "depreciated"]
      f.input :depreciation_date, as: :date_time_picker
      f.input :last_updated_by, as: :hidden, input_html: { value: current_admin_user.name.full }
    end

    # Course Breakdown Information
    panel "Course Breakdown Information" do
      f.has_many :courses, heading: " ", remote: true, allow_destroy: true, new_record: true do |a|
        a.input :course_module_id, as: :search_select, url: admin_course_modules_path,
          fields: [:module_title, :id], display_name: 'module_title', minimum_input_length: 2,
          order_by: 'id_asc'
        a.input :course_title
        a.input :course_code
        a.input :credit_hour, required: true, min: 1, as: :select, collection: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], include_blank: false
        a.input :lecture_hour
        a.input :lab_hour
        a.input :ects, label: "contact hr"
        a.input :course_type, as: :select, collection: ['major', 'elective', 'common', 'supportive']
        a.input :course_description, input_html: { class: 'autogrow', rows: 5, cols: 20 }
        a.input :year, as: :select, collection: [1, 2, 3, 4, 5, 6, 7], include_blank: false
        a.input :semester, as: :select, collection: [1, 2, 3, 4], include_blank: false
        a.input :course_starting_date, as: :date_time_picker
        a.input :course_ending_date, as: :date_time_picker
      end
    end
  
    # Grade System Information
    f.inputs "Grade System Information" do
      f.has_many :grade_systems, allow_destroy: true do |g|
        g.input :min_cgpa_value_to_pass
        g.input :min_cgpa_value_to_graduate
        g.input :remark
        g.input :study_level, as: :select, collection: ['undergraduate', 'graduate']
        g.input :curriculum_id, as: :hidden, input_html: { value: f.object.id }
        g.input :program_id, as: :hidden, input_html: { value: f.object.program_id }
  
        # Grades Section
        g.has_many :grades, allow_destroy: true, new_record: true do |g|
          g.input :letter_grade
          g.input :grade_point
          g.input :min_row_mark
          g.input :max_row_mark
        end
  
        # Academic Status Section
        g.has_many :academic_statuses, allow_destroy: true, new_record: true do |a|
          a.input :status
          a.input :min_value
          a.input :max_value
        end
      end
    end
    f.actions
  end
  
  action_item :edit, only: :show, priority: 1  do
    link_to 'Set Course', edit_admin_curriculum_path(curriculum.id, page_name: "add_course")
  end

  show title: :curriculum_title do
    tabs do
      tab "Curriculum information" do
        panel "Curriculum information" do
          attributes_table_for curriculum do
            row :program_name do |pr|
              link_to pr.program.program_name, admin_program_path(pr.program)
            end
            row :curriculum_title
            row :curriculum_version
            row :batch
            row :total_course
            row :total_ects
            row :total_credit_hour
            row :active_status
            row :curriculum_active_date
            row :depreciation_date
            row :created_by
            row :last_updated_by

            row :created_at
            row :updated_at
          end
        end
      end

      tab "Course Breakdown" do      
        panel "Course Breakdown list" do
          (1..curriculum.program.program_duration).map do |i|
            panel "ClassYear: Year #{i}" do
              (1..curriculum.program.program_semester).map do |s|
                panel "Semester: #{s}" do
                  table_for curriculum.courses.where(year: i, semester: s).order('year ASC','semester ASC') do
                    ## TODO: wordwrap titles and long texts
                    # year
                    # Semester
                    # Curri_id 
                    # study_level
                    # admission_type 
                    # total
                    column "course title" do |item|
                      link_to item.course_title, [ :admin, item] 
                    end
                    column "module code" do |item|
                      item.course_module.module_code
                    end
                    column "course code" do |item|
                      item.course_code
                    end
                    column "credit hour" do |item|
                      item.credit_hour
                    end
                    column :lecture_hour do |item|
                      item.lecture_hour
                    end
                    column :lab_hour do |item|
                      item.lab_hour
                    end
                    column "contact hr." do |item|
                      item.ects
                    end
                    column "Course Type" do |item|
                      status_tag item.course_type, 
                                 class: {
                                   "common" => "status-ok",
                                   "major" => "status-warning",
                                   "elective" => "status-info",
                                   "supportive" => "status-error"
                                 }[item.course_type]
                    end
                    column :created_by
                    # column :last_updated_by
                    column "Add At", sortable: true do |c|
                      c.created_at.strftime("%b %d, %Y")
                    end
                    # column "Starts at", sortable: true do |c|
                    #   c.course_starting_date.strftime("%b %d, %Y") if c.course_starting_date.present?
                    # end
                    # column "ends At", sortable: true do |c|
                    #   c.course_ending_date.strftime("%b %d, %Y") if c.course_ending_date.present?
                    # end
                  end
                end
              end      
            end 
          end    
        end 
      end
      
      tab "Grade System" do
        columns do 
          if curriculum.grade_systems.present?
            column do
              panel "Grading system information" do
                attributes_table_for curriculum.grade_systems do
                  row "Program" do |c|
                    link_to c.program.program_name, admin_program_path(c.program)
                  end
                  row :admission_type do |c|
                    c.program.admission_type
                  end
                  row :study_level do |c|
                    c.program.study_level
                  end
                  row :curriculum do |c|
                    c.curriculum.curriculum_version
                  end
                  row :min_cgpa_value_to_pass
                  row :min_cgpa_value_to_graduate
                  row :remark
                  row :created_at
                  row :updated_at
                end
              end
              
              panel "grade Information" do
                table_for curriculum.grade_systems.first.academic_statuses do
                  column :status
                  column :min_value
                  column :max_value
                end
              end
            end
          end
          if curriculum.grade_systems.present?
            column do
              panel "grade Information" do
                table_for curriculum.grade_systems.first.grades do
                  column :letter_grade
                  column :grade_point
                  column :min_row_mark
                  column :max_row_mark
                end
              end
            end
          end
        end
      end

    end
  end

end
