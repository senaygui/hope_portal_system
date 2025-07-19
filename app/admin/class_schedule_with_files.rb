ActiveAdmin.register ClassScheduleWithFile do
  menu parent: 'Schedules', label: 'Class Schedule Files', priority: 1
  permit_params :name, :class_schedule_file

    index do
      selectable_column
      column :name
      column 'Uploaded At', sortable: true do |cs|
        cs.created_at.strftime('%b %d, %Y')
      end
      column 'Updated At', sortable: true do |cs|
        cs.updated_at.strftime('%b %d, %Y')
      end
      actions
    end

    show do
        attributes_table do
          row :name
          row :class_schedule_file do |cs|
            if cs.class_schedule_file.attached?
              link_to cs.class_schedule_file.filename,
                      rails_blob_path(cs.class_schedule_file, disposition: 'attachment')
            else
              'No file attached'
            end
          end
        end
        # actions do
        #  link_to "Upload File", upload_file_admin_class_schedule_with_file_path(resource)
        # end
    end

    form do |f|
      f.inputs do
        f.input :name
        f.input :class_schedule_file, as: :file
      end
      f.actions
    end
end
