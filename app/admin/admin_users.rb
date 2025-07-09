ActiveAdmin.register AdminUser do
  menu if: false if proc { current_admin_user.role == 'admin' }

  menu priority: 2
  permit_params :photo, :email, :password, :password_confirmation, :first_name, :last_name, :middle_name, :role,
                :username, :faculty_id, :type_of_employment, :gender, :highest_level_educational_achievement, :department_id

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  # collection_action :index, method: :get do
  #  if params[:q].present?
  #    admin_users = AdminUser.ransack(first_name_or_middle_name_or_last_name_cont: params[:q])
  #                           .result(distinct: true)
  #                           .select(:id, :first_name, :middle_name, :last_name)
  #                           .order(params[:order_by] || 'created_at_asc')
  #  else
  #    admin_users = AdminUser.all
  #  end
#
  #  render json: admin_users.map { |user| { id: user.id, full_name: user.full_name } }
  # end

  index do
    selectable_column
    column 'Full Name', sortable: true do |n|
      n.name.full
    end
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :middle_name
  filter :role
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  scope :recently_added
  scope :total_users
  scope :admins
  scope :president
  scope :vice_presidents
  scope :quality_assurances
  scope :deans
  scope :department_heads
  scope :program_offices
  scope :library
  scope :registrars
  scope :finances

  form do |f|
    f.inputs 'Administration Account' do
      f.input :first_name
      f.input :last_name
      f.input :middle_name
      f.input :username
      f.input :email
      f.input :password
      f.input :password_confirmation

      # Role select
      f.input :role, as: :select, collection: [
        ['Data Encoder', 'data encoder'],
        ['Department Head', 'department head'],
        %w[President president],
        ['Vice President', 'vice president'],
        ['Quality Assurance', 'quality assurance'],
        %w[Dean dean],
        ['Program Officer', 'program office'],
        ['Library Head', 'library head'],
        ['Store Head/Student Service', 'store head'],
        %w[Admin admin],
        ['Registrar Head', 'registrar head'],
        ['Distance Registrar', 'distance registrar'],
        ['Online Registrar', 'online registrar'],
        ['Regular Registrar', 'regular registrar'],
        ['Extension Registrar', 'extension registrar'],
        ['Finance Head', 'finance head'],
        ['Distance Finance', 'distance finance'],
        ['Online Finance', 'online finance'],
        ['Regular Finance', 'regular finance'],
        ['Extension Finance', 'extension finance'],
        %w[Instructor instructor]
      ], label: 'Account Role', include_blank: false

      # Faculty input, initially hidden
      # f.input :faculty, as: :select, collection: Faculty.all, label: "Faculty", input_html: { class: 'faculty-select' }
      f.input :faculty, as: :select, collection: Faculty.all.map { |f|
                                                   [f.faculty_name, f.id]
                                                 }, label: 'Faculty', input_html: { class: 'faculty-select' }

      f.input :position, input_html: { class: 'position-select' }
      f.input :educational_level, input_html: { class: 'educational-level-select' }
      f.input :employee_type, as: :select, collection: %w[part_time full_time],
                              input_html: { class: 'employee-type-select' }

      f.input :photo, as: :file
    end
    f.actions
  end

  show title: proc { |admin_user| admin_user.name.full } do
    panel 'Admin User Information' do
      attributes_table_for admin_user do
        row 'Photo' do |pt|
          span image_tag(pt.photo, size: '150x150', class: 'img-corner') if pt.photo.attached?
        end
        row :first_name
        row :last_name
        row :middle_name
        row :username
        row :email
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
        row :created_at
        row :updated_at
      end
    end
  end
end
