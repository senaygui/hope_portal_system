ActiveAdmin.register StudentGrade do
    menu parent: 'Grade'
    permit_params :dean_approval_status, :instructor_submit_status, :instructor_name, :dean_head_name, :department_approval, :department_head_name, :department_head_date_of_response, :course_registration_id,
                  :student_id, :letter_grade, :grade_point, :assesment_total, :grade_point, :course_id, assessments_attributes: %i[id student_grade_id assessment_plan_id student_id course_id result created_by updated_by _destroy]

    # Limit listing: instructors see only their assigned students; admins see all
    controller do
      def scoped_collection
        base = super.includes(:student, :course, course_registration: %i[academic_calendar section])
        return base if current_admin_user.role == 'admin'

        if current_admin_user.role == 'instructor'
          # Join with course_instructors on course_id, section_id, academic_calendar_id
          base
            .joins(:course_registration)
            .joins("INNER JOIN course_instructors ci ON ci.course_id = student_grades.course_id AND ci.section_id = course_registrations.section_id AND ci.academic_calendar_id = course_registrations.academic_calendar_id")
            .where(ci: { admin_user_id: current_admin_user.id })
        else
          base
        end
      end
    end

     active_admin_import validate: true,
                         headers_rewrites: { 'ID': :student_id },
                         before_batch_import: lambda { |importer|
                                                 student_ids = importer.values_at(:student_id)
                                                 # replacing author name with author id
                                                 students = Student.where(student_id: student_ids).pluck(:student_id,
                                                                                                         :id)
                                                 options = Hash[*students.flatten] # #{"Jane" => 2, "John" => 1}
                                                 importer.batch_replace(:student_id, options)
                                              }

    scoped_collection_action :scoped_collection_update, title: 'Approve Grade', form: lambda {
                                                                                        {
                                                                                           department_approval: %w[pending approved denied]
                                                                                         }
                                                                                      }
    member_action :generate_grade, method: :put do
      @student_grade = StudentGrade.find(params[:id])
      @student_grade.generate_grade
      redirect_back(fallback_location: admin_student_grade_path)
    end
    # action_item :update, only: :show do
    #   link_to 'Generate Grade', generate_grade_admin_student_grade_path(student_grade.id), method: :put, data: { confirm: 'Are you sure?' }
    # end
 
    batch_action 'Generate Grade for', method: :put, if: proc {
      current_admin_user.role == 'instructor' || current_admin_user.role == 'admin'
    }, confirm: 'Are you sure?' do |ids|
      StudentGrade.find(ids).each do |student_grade|
        student_grade.generate_grade
        student_grade.update(instructor_submit_status: 'Submitted', instructor_name: "#{current_admin_user.name.full}")
      end
      redirect_to collection_path, notice: 'Grade Is Generated Successfully'
    end
    batch_action 'Department Head Approve Grade for', if: proc {
      current_admin_user.role == 'department head' || current_admin_user.role == 'admin'
    }, method: :put, confirm: 'Are you sure?' do |ids|
      StudentGrade.find(ids).each do |student_grade|
        student_grade.update(department_approval: 'approved', department_head_name: "#{current_admin_user.name.full}",
                             approval_date: Time.now)
      end
      redirect_to collection_path, notice: 'Grade Is Approved Successfully'
    end
    batch_action 'Department Head Denied Grade for', method: :put, if: proc {
                                                                         current_admin_user.role == 'department head' || current_admin_user.role == 'admin'
                                                                       }, confirm: 'Are you sure?' do |ids|
      StudentGrade.find(ids).each do |student_grade|
        student_grade.update(department_approval: 'denied', department_head_name: "#{current_admin_user.name.full}",
                             approval_date: Time.now)
      end
      redirect_to collection_path, notice: 'Grade Is Denied Successfully'
    end
    batch_action 'Dean Approve Grade for', method: :put, if: proc {
      current_admin_user.role == 'dean' || current_admin_user.role == 'admin'
    }, confirm: 'Are you sure?' do |ids|
      StudentGrade.find(ids).each do |student_grade|
        student_grade.update(dean_approval_status: 'approved', dean_head_name: "#{current_admin_user.name.full}")
      end
      redirect_to collection_path, notice: 'Grade Is Approved Successfully'
    end
    batch_action 'Dean Denied Grade for', method: :put, if: proc {
                                                              current_admin_user.role == 'dean' || current_admin_user.role == 'admin'
                                                            }, confirm: 'Are you sure?' do |ids|
      StudentGrade.find(ids).each do |student_grade|
        student_grade.update(dean_head_name: 'denied', dean_approval_status: "#{current_admin_user.name.full}")
      end
      redirect_to collection_path, notice: 'Grade Is Denied Successfully'
    end
    index do
      selectable_column
      column 'Full Name', sortable: 'students.first_name' do |n|
        link_to n.student.full_name, admin_student_path(n.student.id)
      end
      column 'Student ID' do |si|
        si.student.student_id
      end
      column 'Program' do |si|
        link_to si.student.program.program_name, admin_program_path(si.student.program.id)
      end
      column 'Course title' do |si|
        link_to si.course.course_title, admin_course_path(si.course.id)
      end
      column :letter_grade
      column :grade_point
      column :assesment_total
      column :department_approval do |c|
        status_tag c.department_approval
      end
      column :dean_approval_status do |c|
        status_tag c.dean_approval_status
      end
      column :instructor_submit_status do |c|
        status_tag c.instructor_submit_status
      end
      column 'Created At', sortable: true do |c|
        c.created_at.strftime('%b %d, %Y')
      end
      actions defaults: false do |sg|
        # Always show View
        item 'View', admin_student_grade_path(sg)

        submitted = sg.instructor_submit_status.to_s.downcase == 'submitted'

        # Show Edit only if not submitted and authorized
        if !submitted && authorized?(:update, sg)
          item 'Edit', edit_admin_student_grade_path(sg)
        end

        # Show Delete only if not submitted and authorized
        if !submitted && authorized?(:destroy, sg)
          item 'Delete', admin_student_grade_path(sg), method: :delete, data: { confirm: 'Are you sure?' }
        end
      end
    end


    filter :student_id, as: :search_select_filter, url: proc { admin_students_path },
                        fields: %i[student_id id], display_name: 'student_id', minimum_input_length: 2,
                        order_by: 'created_at_asc'
    filter :course_id, as: :search_select_filter, url: proc { admin_courses_path },
                       fields: %i[course_title id], display_name: 'course_title', minimum_input_length: 2,
                       order_by: 'created_at_asc'
    filter :program_id, as: :search_select_filter, url: proc { admin_programs_path },
                        fields: %i[program_name id], display_name: 'program_name', minimum_input_length: 2,
                        order_by: 'created_at_asc'
    filter :department_id, as: :search_select_filter, url: proc { admin_departments_path },
                           fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                           order_by: 'created_at_asc'
    filter :course_registration_year_eq, as: :select,
                                         collection: -> { CourseRegistration.distinct.order(:year).pluck(:year) },
                                         label: 'Year'
    filter :course_registration_semester_eq, as: :select,
                                             collection: lambda {
                                                           CourseRegistration.distinct.order(:semester).pluck(:semester)
                                                         },
                                             label: 'Semester'

    filter :letter_grade
    filter :grade_point
    filter :assesment_total
    filter :department_approval, as: :select, collection: %w[pending approved denied incomplete]
    filter :dean_approval_status, as: :select, collection: %w[pending approved denied incomplete]
    filter :instructor_submit_status, as: :select, collection: %w[not_submitted Submitted]
    filter :created_at
    filter :updated_at
    filter :updated_by
    filter :created_by

    form title: proc { |student| student.student.name.full if student.student.present? } do |f|
      f.semantic_errors

      if object.new_record?
        f.object.assessments << Assessment.new if f.object.assessments.empty?
        panel 'Assessment' do
          f.input :created_by, as: :hidden, input_html: { value: current_admin_user.name.full }

          f.has_many :assessments, heading: ' ', remote: true, allow_destroy: true do |a|
            a.input :student_id, as: :search_select, url: proc { admin_students_path },
                                 fields: %i[student_id id], display_name: 'student_id', minimum_input_length: 2,
                                 order_by: 'created_at_asc'
            a.input :course_id, as: :search_select, url: proc { admin_courses_path },
                                fields: %i[course_title id], display_name: 'course_title', minimum_input_length: 2,
                                order_by: 'created_at_asc'
            a.input :assessment_plan_id, as: :search_select, url: proc { admin_assessment_plans_path },
                                         fields: %i[assessment_title id], display_name: 'assessment_title', minimum_input_length: 2,
                                         order_by: 'created_at_asc'
            a.input :assessment_plan_id, as: :search_select, url: proc { admin_assessment_plans_path },
                                         fields: %i[assessment_title id], display_name: 'assessment_title', minimum_input_length: 2,
                                         order_by: 'created_at_asc', lebel: 'Assessment Plan', input_html: { disabled: true }
            a.input :result
            a.label :_destroy
          end
        end
      end
      if (current_admin_user.role == 'instructor') || (current_admin_user.role == 'admin')
        inputs 'Student Assessment' do
          f.input :updated_by, as: :hidden, input_html: { value: current_admin_user.name.full }
          table(class: 'form-table') do
            tr do
              th 'Assessment Plan', class: 'form-table__col'
              th 'Assessment Weight', class: 'form-table__col'
              th 'Result', class: 'form-table__col'
            end
            f.semantic_fields_for :assessments, f.object.assessments do |a|
              render 'assessment', a: a
              a.input :updated_by, as: :hidden, input_html: { value: current_admin_user.name.full }
            end
          end
        end
      end
      if !f.object.new_record? && (params[:page_name] == 'grade_approve')
        inputs 'Department Approval' do
          f.input :department_approval, as: :select, collection: %w[pending approved denied],
                                        include_blank: false
          f.input :department_head_name, as: :hidden, input_html: { value: current_admin_user.name.full }
          f.input :department_head_date_of_response, as: :hidden, input_html: { value: Time.now }
        end
      end
      f.actions
    end

    action_item :new, only: :show, priority: 0 do
      if (current_admin_user.role == 'registrar head') || (current_admin_user.role == 'admin')
        link_to 'Add Grade Change',
                new_admin_grade_change_path(course_id: "#{student_grade.course.id}",
                                            section_id: "#{student_grade.course_registration.semester_registration.section.id}", academic_calendar_id: "#{student_grade.course_registration.academic_calendar.id}", semester: "#{student_grade.course_registration.semester}", year: "#{student_grade.course_registration.year}", student_id: "#{student_grade.student.id}", course_registration_id: "#{student_grade.course_registration.id}", student_grade_id: "#{student_grade.id}", department_id: "#{student_grade.student.program.department.id}", program_id: "#{student_grade.student.program.id}")
      end
    end

    action_item :new, only: :show, priority: 0 do
      if (current_admin_user.role == 'registrar head') || (current_admin_user.role == 'admin')
        link_to 'Add Makeup exam',
                new_admin_makeup_exam_path(course_id: "#{student_grade.course.id}",
                                           section_id: "#{student_grade.course_registration.semester_registration.section.id}", academic_calendar_id: "#{student_grade.course_registration.academic_calendar.id}", semester: "#{student_grade.course_registration.semester}", year: "#{student_grade.course_registration.year}", student_id: "#{student_grade.student.id}", course_registration_id: "#{student_grade.course_registration.id}", student_grade_id: "#{student_grade.id}", department_id: "#{student_grade.student.program.department.id}", program_id: "#{student_grade.student.program.id}")
      end
    end
    action_item :edit, only: :show, priority: 1  do
      if (current_admin_user.role == 'department head') || (current_admin_user.role == 'admin')
        link_to 'Approve Grade', edit_admin_student_grade_path(student_grade.id, page_name: 'grade_approve')
      end
    end

    show title: proc { |student| student.student.full_name } do
      columns do
        column do
          panel 'Grade information' do
            attributes_table_for student_grade do
              row 'full name', sortable: true do |n|
                link_to n.student.full_name, admin_student_path(n.student.id)
              end
              row 'Student ID' do |si|
                si.student.student_id
              end
              row 'Program' do |pr|
                link_to pr.student.program.program_name, admin_program_path(pr.student.program.id)
              end
              row 'Section' do |si|
                link_to si.course_registration.section.section_full_name,
                        admin_section_path(si.course_registration.section.id)
              end
              row 'Academic Calendar' do |si|
                link_to si.course_registration.academic_calendar.calender_year,
                        admin_academic_calendar_path(si.course_registration.academic_calendar.id)
              end
              row 'Year' do |si|
                si.course_registration.year
              end
              row 'Semester' do |si|
                si.course_registration.semester
              end
              row 'Course title' do |si|
                link_to si.course.course_title, admin_course_path(si.course.id)
              end
              row 'Course code' do |si|
                si.course.course_code
              end
              row :letter_grade
              row :grade_point
              row :assesment_total
              row :instructor_submit_status do |c|
                status_tag c.instructor_submit_status
              end
              row :instructor_name
              row :dean_approval_status do |c|
                status_tag c.dean_approval_status
              end
              row :dean_head_name
              row :department_approval do |c|
                status_tag c.department_approval
              end
              row :department_head_name
              # row 'approval date' do |a|
              #   a.department_head_date_of_response
              # end
              row :created_at
              row :updated_at
            end
          end
        end
        column do
          panel 'Assessments Information' do
            table_for student_grade.assessments do
              column :assessment_plan do |a|
                a.assessment_plan.assessment_title
              end
              column :assessment_weight do |a|
                a.assessment_plan.assessment_weight
              end
              column :result
              column 'Graded At', sortable: true do |c|
                c.updated_at.strftime('%b %d, %Y')
              end
              column 'Graded by', sortable: true do |c|
                c.updated_by
              end
            end
          end
        end
      end
    end
end
