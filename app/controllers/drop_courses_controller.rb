class DropCoursesController < ApplicationController
  def index
    current_semester_registration = current_student.semester_registrations.find_by(semester: current_student.semester, year: current_student.year)
    @courses = CourseRegistration.where(student: current_student, enrollment_status: 'enrolled', semester: current_student.semester, semester_registration_id: current_semester_registration).includes(:course)
    @droped_courses = Dropcourse.where(student: current_student).where.not(status: 0).includes(:course)
  end

  def add_course_drop
     id = params[:id]
    course_registration = CourseRegistration.find(id)
    course_id = params[:course_id]
    semester = params[:semester]
    year = params[:year]

    drop_course = Dropcourse.new(year: year, semester: semester, course_id: course_id, student: current_student, department: current_student.department)
    if drop_course.save
      course_registration.pending!
      redirect_to drop_courses_path, notice: 'You application has been sent to department head'
    else
      redirect_to drop_courses_path, alert: 'Something went wrong, please check again later'
    end
  end

  def withdraw_course
    id = params[:id]
    course_registration = CourseRegistration.find(id)
    course_id = params[:course_id]
    semester = params[:semester]
    year = params[:year]
    drop_course = Dropcourse.where(course_id: course_id, student: current_student, semester: semester, year: year).last
    if drop_course.delete
      course_registration.no_pending!
      redirect_to drop_courses_path, notice: 'You successfully withdraw your application'
    else
      redirect_to drop_courses_path, alert: 'Something went wrong, please check again later'

    end
  end

end
