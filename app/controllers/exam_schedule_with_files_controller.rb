class ExamScheduleWithFilesController < ApplicationController
  def index
    @exam_schedule_files = ExamScheduleWithFile.order(created_at: :desc)
  end

  def show
    @exam_schedule_file = ExamScheduleWithFile.find(params[:id])
    if @exam_schedule_file.exam_schedule_file.attached?
      # Serve the file inline for viewing
      redirect_to rails_blob_url(@exam_schedule_file.exam_schedule_file, disposition: 'inline')
    else
      redirect_to exam_schedule_with_files_path, alert: 'File not found.'
    end
  end
end
