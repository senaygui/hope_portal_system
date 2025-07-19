# app/admin/exam_schedule_with_files.rb
ActiveAdmin.register ExamScheduleWithFile do
  menu parent: 'Schedules', label: 'Exam Schedule Files', priority: 2
  permit_params :name, :exam_schedule_file

  index do
    selectable_column
    column :name
    column :exam_schedule_file do |es|
      if es.exam_schedule_file.attached?
        link_to('Download',
                                                      rails_blob_path(es.exam_schedule_file,
                                                                      disposition: 'attachment'))
      else
        'No file attached'
      end
    end
    column 'Uploaded At', sortable: true do |es|
      es.created_at.strftime('%b %d, %Y')
    end
    column 'Updated At', sortable: true do |es|
      es.updated_at.strftime('%b %d, %Y')
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :exam_schedule_file do |es|
        if es.exam_schedule_file.attached?
          link_to es.exam_schedule_file.filename, rails_blob_path(es.exam_schedule_file, disposition: 'attachment')
        else
          'No file attached'
        end
      end
      row 'Uploaded At' do |es|
        es.created_at.strftime('%b %d, %Y')
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :exam_schedule_file, as: :file
    end
    f.actions
  end
end
