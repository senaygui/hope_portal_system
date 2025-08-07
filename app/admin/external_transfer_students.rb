ActiveAdmin.register Student, as: 'ExternalTransferStudent' do
  menu parent: 'Add-ons'
  # config.batch_actions = true
  permit_params :institution_transfer_status, :section_id, :payment_version, :password_confirmation, :batch, :nationality, :undergraduate_transcript, :highschool_transcript,
                :grade_10_matric, :grade_12_matric, :coc, :diploma_certificate, :degree_certificate, :place_of_birth, :sponsorship_status, :entrance_exam_result_status, :student_id_taken_status, :old_id_number, :curriculum_version, :current_occupation, :tempo_status, :created_by, :last_updated_by, :photo, :email, :password, :first_name, :last_name, :middle_name, :gender, :student_id, :date_of_birth, :program_id, :department, :admission_type, :study_level, :marital_status, :year, :semester, :account_verification_status, :document_verification_status, :account_status, :graduation_status, student_address_attributes: %i[id country city region zone sub_city house_number special_location moblie_number telephone_number pobox woreda created_by last_updated_by], emergency_contact_attributes: %i[id full_name relationship cell_phone email current_occupation name_of_current_employer pobox email_of_employer office_phone_number created_by last_updated_by], school_or_university_information_attributes: %i[id level coc_attendance_date college_or_university phone_number address field_of_specialization cgpa last_attended_high_school school_address grade_10_result grade_10_exam_taken_year grade_12_exam_result grade_12_exam_taken_year created_by updated_by coc_id tvet letter_of_equivalence entrance_exam_id], course_exemptions_attributes: %i[id course_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              letter_grade
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              credit_hour
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              course_taken
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              exemption_approval
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              exemption_type
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              exemptible_type
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              exemptible_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              created_by
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              updated_by
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              created_at updated_at _destroy]

 # active_admin_import validate: false,
 #                     before_batch_import: proc { |import|
 #                       import.csv_lines.length.times do |i|
 #                         import.csv_lines[i][1] =
 #                           Student.new(password: import.csv_lines[i][1]).encrypted_password
 #                       end
 #                     },
 #                     timestamps: true,
 #                     batch_size: 1000
 # scoped_collection_action :scoped_collection_update, title: "Batch Approve", form: lambda {
 #                              {
 #                                document_verification_status: %w[pending approved denied incomplete],
#
 #                              }
 #                            }

  active_admin_import(
     validate: false,
     timestamps: true,
     batch_size: 1000,
     headers_rewrites: {
       'Phone number' => :phone_number,  # Maps CSV "Phone Number" to the `mobile_number` column in student_addresses
       'Grade 10 Result' => :grade_10_result,
       'Grade 10 Year' => :grade_10_exam_taken_year,
       'Grade 12 Result' => :grade_12_exam_result,
       'Grade 12 Year' => :grade_12_exam_taken_year,
       'Entrance Exam ID Number' => :entrance_exam_id,
       'Letter of Equivalence' => :letter_of_equivalence,
       'TVET/12+2 Program Attend' => :college_or_university,
       'Level(L3,L4)' => :level,
       'Coc ID' => :coc_id,
       'Coc Attended Date' => :coc_attendance_date
     },

     before_batch_import: lambda { |import|
       headers = import.csv_lines.first  # Get the headers from the first row
       puts "CSV Headers: #{headers.inspect}"  # Debugging step

       student_id_index = headers.index('student_id') || headers.index('Student ID')
       raise "Error: 'student_id' column not found! Available headers: #{headers.inspect}" unless student_id_index

       import.csv_lines.drop(1).each do |row|  # Skip header row
         external_transfer_student = Student.find_or_initialize_by(student_id: row[student_id_index])

         external_transfer_student.assign_attributes(
           first_name: row[headers.index('first_name')],
           middle_name: row[headers.index('middle_name')],
           last_name: row[headers.index('last_name')],
           gender: row[headers.index('gender')],
           nationality: row[headers.index('nationality')],
           date_of_birth: row[headers.index('date_of_birth')],
           email: row[headers.index('email')],
           password: row[headers.index('encrypted_password')],
           admission_type: row[headers.index('admission_type')],
           study_level: row[headers.index('study_level')],
           entrance_exam_result_status: row[headers.index('entrance_exam_result_status')]
         )

         program_name = row[headers.index('NameofProgram')] # Ensure the column name is correct
         if program_name.blank?
           puts "Warning: 'NameofProgram' is blank for student_id: #{row[student_id_index]}"
         else
           program = Program.find_by(program_name:)
           if program
             external_transfer_student.program_id = program.id # Assign program_id if found
           else
             puts "Warning: Program '#{program_name}' not found for student_id: #{row[student_id_index]}"
           end
         end

         # ✅ Handling `student_addresses`
         external_transfer_student.student_address ||= StudentAddress.new
         if headers.include?('Phone number')
           external_transfer_student.student_address.moblie_number = row[headers.index('Phone number')]
         end

         # ✅ Handling `school_or_university_information`
         external_transfer_student.school_or_university_information ||= SchoolOrUniversityInformation.new
         external_transfer_student.school_or_university_information.assign_attributes(
           grade_10_result: row[headers.index('Grade 10  result')],
           grade_10_exam_taken_year: row[headers.index('Grade 10  Year')],
           grade_12_exam_result: row[headers.index('Grade 12 Result')],
           grade_12_exam_taken_year: row[headers.index('Grade 12 Year')],
           entrance_exam_id: row[headers.index('Entrance Exam ID Number')],
           letter_of_equivalence: row[headers.index('Letter of Equivalence')],
           college_or_university: row[headers.index('TVET')],
           level: row[headers.index('Level')],
           coc_id: row[headers.index('Coc ID')],
           coc_attendance_date: row[headers.index('Coc Attended Date')]
         )

         external_transfer_student.save!
         external_transfer_student.student_address&.save!
         external_transfer_student.school_or_university_information&.save!
       end
     }
   )

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update : :update_without_password
      object.send(update_method, *attributes)
    end

    def scoped_collection
      super.where(institution_transfer_status: %w[approved pending denied incomplete])
    end
  end

  def scoped_collection
    super.includes(:school_or_university_information, :curriculum)
  end

  csv do
    serial = 0

    column 'No.' do |_resource|
      serial += 1
    end
    column 'Name Of HEI' do
      'Hope Enterprise University College'
    end
    column 'Campus' do
      'Hope Lebu'
    end
    column 'Location/Town' do
      'Addis Ababa'
    end
    column('Name of Program') { |external_transfer_student| external_transfer_student.program&.program_name }
    column('Modality', &:admission_type)
    column('Addmission Date', &:created_at)
    column('Id Number', &:student_id)
    column('First Name', &:first_name)
    column('Middle Name', &:middle_name)
    column('Last Name', &:last_name)
    column('Gender', &:gender)
    column('Citizenship', &:nationality)
    column('Date Of Birth', &:date_of_birth)

    column('Grade 10 Result') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.grade_10_result || 'N/A'
    end
    column('Grade 10  Year') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.grade_10_exam_taken_year || 'N/A'
    end
    column('Grade 12 Result') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.grade_12_exam_result || 'N/A'
    end
    column('Grade 12 Year') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.grade_12_exam_taken_year || 'N/A'
    end
    column('TVET/12+2 Program Attend') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.tvet_program_attend || 'N/A'
    end

    column('Level(L3,L4') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.tvet_level || 'N/A'
    end
    column('Coc ID') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.coc_id || 'N/A'
    end
    column('Coc Attended Date') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.coc_attended_date || 'N/A'
    end
    column('Degree Attended') do |external_transfer_student|
      external_transfer_student.school_or_university_information&.field_of_specialization || 'N/A'
    end
    # column("Degree Attended") { |student| student.school_or_university_information&.degree_attended } # Adjust based on your actual field name
    # column("Total Credit Hour") { |student| student.curriculum&.total_credit_hour } # Adjust based on your actual field name
    # column("GPA") { |student| student.school_or_university_information&.cgpa }
  end

  index do
    selectable_column
    column :student_id
    column 'Full Name', sortable: true do |n|
      "#{n.first_name.upcase} #{n.middle_name.upcase} #{n.last_name.upcase}"
    end
    column 'Department', sortable: true do |d|
      link_to d.program.department.department_name, [:admin, d.program.department] if d.program.present?
    end
    column 'Program', sortable: true do |d|
      if d.program.present?
        link_to d.program.program_name, [:admin, d.program]
      else
        link_to 'Please add program type', edit_admin_student_path(d)
      end
    end
    column :study_level do |level|
      level.study_level.capitalize
    end
    column :admission_type do |type|
      type.admission_type.capitalize
    end
    column :institution_transfer_status do |s|
      status_tag s.institution_transfer_status.capitalize
    end
    column 'Document Verification' do |s|
      status_tag s.document_verification_status
    end
    column 'Account Verification' do |s|
      status_tag s.account_verification_status
    end
    column 'Admission', sortable: true do |c|
      c.created_at.strftime('%b %d, %Y')
    end
    actions
  end

  filter :first_name
  filter :last_name
  filter :middle_name
  filter :gender
  filter :program_id, as: :search_select_filter, url: proc { admin_programs_path },
                      fields: %i[program_name id], display_name: 'program_name', minimum_input_length: 2,
                      order_by: 'id_asc'
  filter :study_level, as: :select, collection: %w[undergraduate graduate]
  filter :admission_type, as: :select, collection: %w[online regular extention distance]
  filter :department_id, as: :search_select_filter, url: proc { admin_departments_path },
                         fields: %i[department_name id], display_name: 'department_name', minimum_input_length: 2,
                         order_by: 'id_asc'
  filter :year
  filter :semester
  filter :batch
  filter :current_occupation
  filter :nationality
  filter :curriculum_version
  filter :account_verification_status, as: :select, collection: %w[pending approved denied incomplete]
  filter :document_verification_status, as: :select, collection: %w[pending approved denied incomplete]
  filter :entrance_exam_result_status
  filter :account_status, as: :select, collection: %w[active suspended]
  filter :graduation_status
  filter :sponsorship_status
  filter :created_by
  filter :last_updated_by
  filter :created_at
  filter :updated_at

  # TODO: color label scopes
  scope :sponsored_students do |external_transfer_students|
    external_transfer_students.where(sponsorship_status: 'true')
  end
  scope :recently_added
  scope :pending do |external_transfer_students|
    external_transfer_students.where(institution_transfer_status: 'pending')
  end
  scope :approved do |external_transfer_students|
    external_transfer_students.where(institution_transfer_status: 'approved')
  end
  scope :denied do |external_transfer_students|
    external_transfer_students.where(institution_transfer_status: 'denied')
  end
  scope :incomplete do |external_transfer_students|
    external_transfer_students.where(institution_transfer_status: 'incomplete')
  end
  scope :undergraduate
  scope :graduate

  scope :online, if: proc { current_admin_user.role == 'admin' }
  scope :regular, if: proc { current_admin_user.role == 'admin' }
  scope :extention, if: proc { current_admin_user.role == 'admin' }
  scope :distance, if: proc { current_admin_user.role == 'admin' }
  scope :no_section, if: proc { current_admin_user.role == 'admin' }

  form do |f|
    f.semantic_errors
    f.semantic_errors(*f.object.errors.attribute_names)
    # if f.object.errors.key?
    # if f.object.new_record? || current_admin_user.role == "registrar head"
    if current_admin_user.role == 'registrar head' || current_admin_user.role == "admin"
      f.inputs 'Student basic information' do
        f.input :semester
        f.input :year
        f.input :batch, as: :select, collection: [
                  '2019/2020',
                  '2020/2021',
                  '2021/2022',
                  '2022/2023',
                  '2023/2024',
                  '2024/2025',
                  '2025/2026',
                  '2026/2027',
                  '2027/2028',
                  '2028/2029',
                  '2029/2030'
                ], include_blank: false
        if f.object.new_record?
          f.input :created_by, as: :hidden, input_html: { value: current_admin_user.name.full }
          f.input :year, as: :hidden, input_html: { value: 1 }
          f.input :semester, as: :hidden, input_html: { value: 1 }
        end
      end
    end
    if current_admin_user.role == 'registrar head' || current_admin_user.role == "admin"
      f.inputs 'Student account and document verification' do
        f.input :account_verification_status, as: :select, collection: %w[pending approved denied incomplete],
                                              include_blank: false
        f.input :document_verification_status, as: :select,
                                               collection: %w[pending approved denied incomplete], include_blank: false
      end
      f.inputs 'Student transfer status' do
        f.input :institution_transfer_status, as: :select, collection: %w[pending approved denied incomplete],
                                              include_blank: false
      end
    end
    unless f.object.new_record?
      f.input :last_updated_by, as: :hidden,
                                input_html: { value: current_admin_user.name.full }
    end
    panel 'course exemptions' do
      f.has_many :course_exemptions, heading: ' ', remote: true, allow_destroy: true, new_record: true do |a|
            a.input :course_id, as: :search_select, url: admin_courses_path,
                                fields: %i[course_title id], display_name: 'course_title', minimum_input_length: 2,
                                order_by: 'id_asc'
            a.input :letter_grade
            a.input :credit_hour
            a.input :course_taken
            a.input :exemption_approval, as: :select, collection: %w[Pending Approved Rejected]
            a.label :_destroy
      end
    end
    f.actions
  end

  action_item :edit, only: :show, priority: 0 do
    link_to 'Approve Student',
            edit_admin_external_transfer_student_path(external_transfer_student.id, page_name: 'approval')
  end

  show title: proc { |external_transfer_student|
    truncate("#{external_transfer_student.first_name.upcase} #{external_transfer_student.middle_name.upcase} #{external_transfer_student.last_name.upcase}",
             length: 50)
  } do
    tabs do
      tab 'student General information' do
        columns do
          column do
            panel 'Student Main information' do
              attributes_table_for external_transfer_student do
                row 'photo' do |pt|
                  span image_tag(pt.photo, size: '150x150', class: 'img-corner') if pt.photo.attached?
                end
                row 'full name', sortable: true do |n|
                  "#{n.first_name.upcase} #{n.middle_name.upcase} #{n.last_name.upcase}"
                end
                row 'Student ID' do |si|
                  si.student_id
                end
                row 'Program' do |pr|
                  link_to pr.program.program_name, admin_program_path(pr.program.id)
                end
                row :curriculum_version
                row :payment_version
                row 'Department' do |pr|
                  if pr.department.present?
                    link_to(pr.department.department_name,
                            admin_department_path(pr.department.id))
                  end
                end
                row :admission_type
                row :study_level
                row 'Academic year' do |si|
                  if si.academic_calendar.present?
                    link_to(si.academic_calendar.calender_year_in_gc,
                            admin_academic_calendar_path(si.academic_calendar))
                  end
                end
                row :year
                row :semester
                row :batch
                row :account_verification_status do |s|
                  status_tag s.account_verification_status
                end
                row :entrance_exam_result_status
                row 'admission Date' do |d|
                  d.created_at.strftime('%b %d, %Y')
                end
                row :student_id_taken_status
                row :old_id_number
                row :tvet_program_attend
                row :tvet_level
                row :coc_attended_date
                row :coc_id

                # row :graduation_status
              end
            end
          end
          column do
            panel 'Basic information' do
              attributes_table_for external_transfer_student do
                row :email
                row :gender
                row :date_of_birth, sortable: true do |c|
                  c.date_of_birth.strftime('%b %d, %Y')
                end
                row :nationality
                row :place_of_birth
                row :marital_status
                row :current_occupation
                row :student_password
              end
            end
            panel 'Account status information' do
              attributes_table_for external_transfer_student do
                row :institution_transfer_status do |s|
                  status_tag s.institution_transfer_status.capitalize
                end
                row :account_verification_status do |s|
                  status_tag s.account_verification_status
                end
                row :document_verification_status do |s|
                  status_tag s.document_verification_status
                end
                row :account_status do |s|
                  status_tag s.account_status
                end
                row :sign_in_count, default: 0, null: false
                row :current_sign_in_at
                row :last_sign_in_at
                row :current_sign_in_ip
                row :last_sign_in_ip
                row :created_by
                row :last_updated_by
                row :created_at
                row :updated_at
              end
            end
          end
        end
      end
      tab 'Student Documents ' do
        columns do
          column do
            panel 'High School Information' do
              attributes_table_for external_transfer_student.school_or_university_information do
                row :last_attended_high_school
                row :school_address
                row :grade_10_result
                row :grade_10_exam_taken_year
                row :grade_12_exam_result
                row :grade_12_exam_taken_year
              end
            end
          end
          column do
            panel 'University/College Information' do
              attributes_table_for external_transfer_student.school_or_university_information do
                row :college_or_university
                row :phone_number
                row :address
                row :field_of_specialization
                row :level
                row :coc_attendance_date
                row :cgpa
                row :tvet_program_attend
                row :tvet_level
                row :coc_attended_date
                row :coc_id
              end
            end
          end
        end
        columns do
          column do
            panel 'Highschool Transcript' do
              if external_transfer_student.highschool_transcript.attached?
                if external_transfer_student.highschool_transcript.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.highschool_transcript, size: '200x270'),
                                 external_transfer_student.highschool_transcript
                  end
                elsif external_transfer_student.highschool_transcript.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.highschool_transcript,
                                                 disposition: 'preview')
                    # span link_to image_tag(student.highschool_transcript.preview(resize: '200x200')), student.highschool_transcript
                  end
                else
                  # span link_to "view document", student.highschool_transcript.service_url
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.highschool_transcript, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
            panel 'TVET/Diploma Certificate' do
              if external_transfer_student.diploma_certificate.attached?
                if external_transfer_student.diploma_certificate.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.diploma_certificate, size: '200x270'),
                                 external_transfer_student.diploma_certificate
                  end
                elsif external_transfer_student.diploma_certificate.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.diploma_certificate, disposition: 'preview')
                    # span link_to image_tag(student.diploma_certificate.preview(resize: '200x200')), student.diploma_certificate
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.diploma_certificate, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
          end
          column do
            panel 'Grade 10 Matric Certificate' do
              if external_transfer_student.grade_10_matric.attached?
                if external_transfer_student.grade_10_matric.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.grade_10_matric, size: '200x270'),
                                 external_transfer_student.grade_10_matric
                  end
                elsif external_transfer_student.grade_10_matric.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.grade_10_matric, disposition: 'preview')
                    # span link_to image_tag(student.grade_10_matric.preview(resize: '200x200')), student.grade_10_matric
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.grade_10_matric, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
            panel 'Certificate Of Competency(COC)' do
              if external_transfer_student.coc.attached?
                if external_transfer_student.coc.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.coc, size: '200x270'),
                                 external_transfer_student.coc
                  end
                elsif external_transfer_student.coc.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document', rails_blob_path(external_transfer_student.coc, disposition: 'preview')
                    # span link_to image_tag(external_transfer_student.coc.preview(resize: '200x200')), external_transfer_student.coc
                  end
                else
                  span link_to 'view document', rails_blob_path(external_transfer_student.coc, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
          end
          column do
            panel 'Grade 12 Matric Certificate' do
              if external_transfer_student.grade_12_matric.attached?
                if external_transfer_student.grade_12_matric.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.grade_12_matric, size: '200x270'),
                                 external_transfer_student.grade_12_matric
                  end
                elsif external_transfer_student.grade_12_matric.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.grade_12_matric, disposition: 'preview')
                    # span link_to image_tag(external_transfer_student.grade_12_matric.preview(resize: '200x200')), external_transfer_student.grade_12_matric
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.grade_12_matric, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
            panel 'Undergraduate Degree Transcript' do
              if external_transfer_student.undergraduate_transcript.attached?
                if external_transfer_student.undergraduate_transcript.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.undergraduate_transcript, size: '200x270'),
                                 external_transfer_student.undergraduate_transcript
                  end
                elsif external_transfer_student.undergraduate_transcript.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.undergraduate_transcript,
                                                 disposition: 'preview')
                    # span link_to image_tag(external_transfer_student.undergraduate_transcript.preview(resize: '200x200')), external_transfer_student.undergraduate_transcript
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.undergraduate_transcript,
                                               disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Document Not Uploaded Yet'
                end
              end
            end
          end
          column do
            panel 'Student Transcript' do
              if external_transfer_student.student_copy.attached?
                if external_transfer_student.student_copy.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.student_copy, size: '200x270'),
                                 external_transfer_student.student_copy
                  end
                elsif external_transfer_student.student_copy.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.student_copy, disposition: 'preview')
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.student_copy, disposition: 'preview')
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Not Uploaded Yet'
                end
              end
            end
            panel 'Undergraduate Degree Certificate' do
              if external_transfer_student.degree_certificate.attached?
                if external_transfer_student.degree_certificate.variable?
                  div class: 'preview-card text-center' do
                    span link_to image_tag(external_transfer_student.degree_certificate, size: '200x270'),
                                 external_transfer_student.degree_certificate
                  end
                elsif external_transfer_student.degree_certificate.previewable?
                  div class: 'preview-card text-center' do
                    span link_to 'view document',
                                 rails_blob_path(external_transfer_student.degree_certificate, disposition: 'preview')
                    # span link_to image_tag(external_transfer_student.degree_certificate.preview(resize: '200x200')), external_transfer_student.degree_certificate
                  end
                else
                  span link_to 'view document',
                               rails_blob_path(external_transfer_student.degree_certificate, disposition: 'preview')
                end

                div class: 'text-center' do
                  span 'Temporary Degree Status'
                  status_tag external_transfer_student.tempo_status
                end
              else
                h3 class: 'text-center no-recent-data' do
                  'Not Uploaded Yet'
                end
              end
            end
          end
        end
      end
      tab 'Student Address' do
        columns do
          column do
            panel 'Student Address' do
              attributes_table_for external_transfer_student.student_address do
                row :country
                row :city
                row :region
                row :zone
                row :sub_city
                row :house_number
                row :special_location
                row :moblie_number
                row :telephone_number
                row :pobox
                row :woreda
              end
            end
          end
          column do
            panel 'Student Emergency Contact information' do
              attributes_table_for external_transfer_student.emergency_contact do
                row :full_name
                row :relationship
                row :cell_phone
                row :email
                row :current_occupation
                row :name_of_current_employer
                row :email_of_employer
                row :office_phone_number
                row :pobox
              end
            end
          end
        end
      end
      tab 'Course Exemptions' do
        panel 'Course Exemption Details' do
          table_for external_transfer_student.course_exemptions do
            column :course do |exemption|
              exemption.course&.course_title
            end
            column :letter_grade
            column :credit_hour
            column :course_taken
            column :exemption_approval do |exemption|
              status_tag exemption.exemption_approval
            end
          end
        end
      end
    end
  end
end
