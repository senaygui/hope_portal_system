# app/controllers/admin/courses_controller.rb
def index
  if params[:program_id].present?
    program = Program.find_by(id: params[:program_id])
    # Return an empty array if program not found, instead of crashing.
    @courses = program ? program.courses : Course.none
  else
    @courses = Course.all
  end

  # Your search logic (Ransack, etc.) would go here
  # ...

  render json: @courses.as_json(only: [:id, :course_title])
end