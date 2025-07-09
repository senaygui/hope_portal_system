class GraduateStudentsController < ApplicationController
  def student_tempo
    @graduate_student = Student.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "student_tempo_#{@graduate_student.first_name}",
               template: 'graduate_students/student_tempo',
               layout: 'pdf'
      end
    end
  end
end
