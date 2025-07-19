class ClassScheduleWithFilesController < ApplicationController
  def index
    @class_schedule_files = ClassScheduleWithFile.order(created_at: :desc)
  end

  def show
    @class_schedule_file = ClassScheduleWithFile.find(params[:id])
    if @class_schedule_file.class_schedule_file.attached?
      # Serve the file inline for viewing
      redirect_to rails_blob_url(@class_schedule_file.class_schedule_file, disposition: 'inline')
    else
      redirect_to class_schedule_with_files_path, alert: 'File not found.'
    end
  end
end
