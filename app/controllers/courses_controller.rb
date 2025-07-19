class CoursesController < ApplicationController
    def index
        student_curriculum = current_student.program.curriculums.find_by(curriculum_version: current_student.curriculum_version)
        @courses = Course.includes(:program, :curriculum)
                         .where(program: current_student.program, curriculum: student_curriculum, year: current_student.year, semester: current_student.semester)
    end

      # Other actions can be added here (show, new, edit, create, update, destroy)

      def pdf_by_scope
        scope = params[:scope]
        courses = filtered_courses(scope)

        pdf = CoursesPdf.new(courses)

        send_data pdf.render, filename: "courses_#{scope}.pdf", type: 'application/pdf', disposition: 'inline'
      end

      def update
        if @course.update(course_params)
          redirect_to course_assessment_plans_path(@course), notice: 'Course was successfully updated.'
        else
          render :edit
        end
      end

      def create_assessment_plan
        @assessment_plan = @course.assessment_plans.new(assessment_plan_params)
        if @assessment_plan.save
          redirect_to course_assessment_plans_path(@course), notice: 'Assessment Plan was successfully created.'
        else
          render :edit, notice: 'Assessment Plan NOT created.' # Adjust as necessary
        end
      end

      def update_assessment_plan
        @assessment_plan = @course.assessment_plans.find(params[:id])
        if @assessment_plan.update(assessment_plan_params)
          redirect_to course_assessment_plans_path(@course), notice: 'Assessment Plan was successfully updated.'
        else
          render :edit # Adjust as necessary
        end
      end

      private

      # def filtered_courses(scope)
      #  case scope
      #  when 'regular_year_1_semester_1'
      #    Course.joins(:program).where(year: 1, semester: 1, programs: { admission_type: 'regular' })
      #  when 'extension_year_1_semester_1'
      #    Course.joins(:program).where(year: 1, semester: 1, programs: { admission_type: 'extension' })
      #  # Add more cases for other scopes
      #  else
      #    Course.none
      #  end
      # end

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.require(:course).permit(:course_module_id, :curriculum_id, :program_id, :course_title, :course_code,
                                       :course_description, :year, :semester, :course_starting_date, :course_ending_date, :credit_hour, :lecture_hour, :lab_hour, :ects, :created_by, :last_updated_by, :major, :batch)
      end

      def assessment_plan_params
        params.require(:assessment_plan).permit(:assessment_title, :assessment_weight, :final_exam, :created_by,
                                                :updated_by, :admin_user_id)
      end
end
