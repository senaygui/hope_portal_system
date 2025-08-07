class StudentCopyController < ApplicationController
    add_flash_types :success
    def index
      @disable_nav = true
      @department = Department.select(:department_name, :id)
      @year = Student.distinct.select(:graduation_year).where.not(graduation_year: nil)
    end

      def generate_student_copy
        graduation_year = params[:year][:name]
        department_id = params[:department][:name]
        department = Department.find(department_id)

        gc_date = params[:gc][:date]
        students = Student.where(department:).where(graduation_year:).where(graduation_status: 'approved').includes(:course_registrations).includes(:student_grades)
        if students.empty?
          redirect_to student_copy_url,
                      alert: 'We could not find a student matching your search criteria. Did you check student graduation status is approved?'
        end
        if students.any?
          respond_to do |format|
            format.html
            format.pdf do
              pdf = StudentCopy.new(students, gc_date)
              send_data pdf.render, filename: "Student copy at #{Time.now}.pdf", type: 'application/pdf',
                                    disposition: 'inline'
            end
          end
        end
      end

    def show
      @student = Student.find_by(id: params[:id])
      @semesters = @student.grade_reports.order(:year, :semester)
      @course_exemptions = @student.course_exemptions.where(exemption_approval: 'Approved')
      total_credit_hours = Curriculum.where(curriculum_version: @student.curriculum_version).last&.total_credit_hour
      total_grade_points = @semesters.sum(&:total_grade_point)
      @total_cumulative_gpa = (total_credit_hours / total_grade_points.to_f).round(2)

      major_grades = @student.student_grades.joins(:course).where(courses: { major: true })
      total_major_grade_points = major_grades.sum { |sg| (sg.grade_point || 0) * (sg.course.credit_hour || 0) }
      total_major_credit_hours = major_grades.sum { |sg| sg.course.credit_hour || 0 }
      @major_cgpa = if total_major_credit_hours > 0
                      (total_major_grade_points / total_major_credit_hours.to_f).round(2)
                    else
                      0.0
                    end
      
      respond_to do |format|
        format.html
        format.pdf do
          if @student.institution_transfer_status.nil?
            render pdf: "student_copy_#{@student.first_name}",
                 template: 'student_copy/show',
                 layout: 'pdf'
          elsif @student.institution_transfer_status == 'approved'
            render pdf: "student_copy_#{@student.first_name}",
                   template: 'student_copy/transfer',
                   layout: 'pdf'
          end
        end
      end
    end
end
