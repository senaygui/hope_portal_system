ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      tabs do
        tab :student_related_report do
          div class: 'widget-container' do
            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer', id: 'admission' do
                div class: 'left' do
                  span 'admission type ', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.admission_report.each do |key, value|
                      div do
                        span "#{key}: "
                        span "#{value} student".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('address-card')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#chart', class: 'link', id: 'student'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'study level', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.graduation_status.each do |key, value|
                      div do
                        span "#{key}: "
                        span "#{value} student".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('address-card')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#study_level', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'departement', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.departement.each do |key, value|
                      div do
                        span "#{key}: "
                        span "#{value} student".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon 'object-group'
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#student_in_dept', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Program', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.program.each do |key, value|
                      div do
                        span "#{key}: "
                        span "#{value} student".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('calendar-days')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#student_in_program', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Document verification', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.document_verification.each do |key, value|
                      div do
                        span "#{key}: ".camelize
                        span "#{value} document".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon 'book'
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#document_verification', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Account verification', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.account_verification.each do |key, value|
                      div do
                        span "#{key}: ".camelize
                        span "#{value} account".pluralize(value)
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('book')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#account_verification', class: 'link'
                  end
                end
              end
            end
          end

          if RoleFilter.allowed_for_common(current_admin_user)
            div class: 'main-chart-container' do
              div id: 'chart', class: 'left' do
                div class: 'main-chart1' do
                  column_chart DashboardReport.chart_batch,
                               dataset: { barThickness: 80, maxBarThickness: 100, borderColor: '#ccc', borderWidth: 6, clip: true, label: 'Number of student', barPercentage: 10, backgroundColor: 'red' }, title: 'All Students in each batch', download: { filename: 'students', background: '#fff' }, stacked: true, colors: ['#fff', '#f2f2f2'], empty: 'There is no student'
                end
              end
              div class: 'right' do
                div do
                  pie_chart DashboardReport.chart_addmission_type,
                            dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Student Admission Type', download: { filename: 'admission', background: '#fff' }
                end
              end
            end
          end
          hr
          div class: 'main-chart-container' do
            div class: 'other-chart', id: 'study_level' do
              column_chart DashboardReport.chart_study_level,
                           dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Students study level', download: { filename: 'study_level', background: '#fff' }
            end

            div class: 'other-chart', id: 'student_in_dept' do
              pie_chart DashboardReport.chart_departement,
                        dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Students in each departement', download: { filename: 'student_in_dept', background: '#fff' }
            end

            div class: 'other-chart', id: 'student_in_program' do
              pie_chart DashboardReport.chart_program,
                        dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Students in each program', download: { filename: 'student_in_program', background: '#fff' }
            end

            div class: 'other-chart', id: 'account_verification' do
              pie_chart DashboardReport.chart_account_verification, donut: true,
                                                                    dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Account Verification Status', download: { filename: 'account_verification', background: '#fff' }
            end

            div class: 'other-chart', id: 'document_verification' do
              pie_chart DashboardReport.chart_document_verification, donut: true,
                                                                     dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Document Verification Status', download: { filename: 'document_verification', background: '#fff' }
            end
          end
        end

        tab :general_report do
          div class: 'widget-container' do
            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'departement in faculity', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.faculties.each do |key, value|
                      div do
                        span "#{key}: "
                        span value
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('calendar-days')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#dept_in_faculity', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Courses in program', class: 'widget-title'
                  div class: 'each' do
                    DashboardReport.courses.each do |key, value|
                      div do
                        span "#{key}: "
                        span value
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('calendar-days')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#course_in_program', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Programs in department', class: 'widget-title'
                  div class: 'each' do
                    if current_admin_user.role == 'department head'
                      DashboardReport.department_head_filter(current_admin_user).each do |key, value|
                        div do
                          span "#{key}: "
                          span "#{value} program".pluralize(value)
                        end
                      end
                    else
                      DashboardReport.departement_and_program.each do |key, value|
                        div do
                          span "#{key}: "
                          span "#{value} program".pluralize(value)
                        end
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('user-pen')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#program_in_dept', class: 'link'
                  end
                end
              end
            end

            if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
              div class: 'widget widgetContainer' do
                div class: 'left' do
                  span 'Curriculums in program', class: 'widget-title'
                  div class: 'each' do
                    if current_admin_user.role == 'department head'
                      DashboardReport.department_curriculum_filter(current_admin_user).each do |key, value|
                        div do
                          span "#{key}: "
                          span "#{value} program".pluralize(value)
                        end
                      end
                    else
                      DashboardReport.program_and_curriculum.each do |key, value|
                        div do
                          span "#{key}: "
                          span "#{value} curriculum".pluralize(value)
                        end
                      end
                    end
                  end
                end
                div class: 'right' do
                  div class: 'icon' do
                    fa_icon('id-card')
                    # fa_icon ('fa-regular', 'calendar-days')
                  end
                  div class: '' do
                    link_to 'See More', '/admin/dashboard#curriculum_in_program', class: 'link'
                  end
                end
              end
            end
          end

          if RoleFilter.allowed_for_common(current_admin_user)
            div class: 'main-chart-container' do
              div id: 'dept_in_faculity', class: 'left' do
                div class: 'main-chart1' do
                  column_chart DashboardReport.chart_departement_and_faculity,
                               dataset: { barThickness: 80, maxBarThickness: 100, borderColor: '#ccc', borderWidth: 6, clip: true, label: 'Number of departement', barPercentage: 10, backgroundColor: 'red' }, title: 'All departement in each faculity', download: { filename: 'departements', background: '#fff' }, stacked: true, colors: ['#fff', '#f2f2f2'], empty: 'There is no departement'
                end
              end
              div class: 'right', id: 'course_in_program' do
                div do
                  pie_chart DashboardReport.chart_course_and_program,
                            dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Course in each program', download: { filename: 'course', background: '#fff' }
                end
              end
            end
          end
          div class: 'main-chart-container' do
            div class: 'other-chart', id: 'program_in_dept' do
              pie_chart DashboardReport.chart_departement_program,
                        dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Programs in each department', download: { filename: 'department', background: '#fff' }
            end

            div class: 'other-chart', id: 'curriculum_in_program' do
              pie_chart DashboardReport.chart_program_and_curriculum,
                        dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Curriculums in each Program', download: { filename: 'curriculum_in_program', background: '#fff' }
            end
          end
        end

        tab :invoice do
          if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == 'department head'
            div class: 'widget widgetContainer' do
              div class: 'left' do
                span 'Invoice Report ', class: 'widget-title'
                div class: 'each' do
                  DashboardReport.invoice_report.each do |key, value|
                    div do
                      span "#{key[0]}: #{key[1]}"
                      span "#{value} student".pluralize(value)
                    end
                  end
                end
              end
              div class: 'right' do
                div class: 'icon' do
                  fa_icon('address-card')
                end
                div class: '' do
                  link_to 'See More', '/admin/dashboard#invoive_report', class: 'link'
                end
              end
            end
          end
          div class: 'main-chart-container' do
            div class: 'other-chart', id: 'invoive_report' do
              pie_chart DashboardReport.chart_invoice_report,
                        dataset: { borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2' }, title: 'Invoice report in each program', download: { filename: 'invoice', background: '#fff' }
            end
          end
        end

        tab :instructor do
          div style: 'margin-bottom: 20px; text-align: right;' do
            link_to 'Download Instructor Report (CSV)',
                    url_for(controller: 'admin/dashboard', action: 'download_instructor_report', format: :csv),
                    class: 'button'
          end
          div class: 'widget-container' do
            # Determine which departments to show
            selected_department_id = params[:department_id].presence
            first_department = Department.order(:created_at).first
            selected_department_id = first_department.id.to_s if selected_department_id.blank? && first_department

            # Top bar with download button right, filter left
            div style: 'display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;' do
              # Filter left
              form action: request.path, method: :get,
                   style: 'display: flex; align-items: center; gap: 10px; margin: 0;' do
                label 'Select Department:', for: 'department_id',
                                            style: 'margin-right: 5px; font-weight: bold; width: 200px;'
                select name: 'department_id', id: 'department_id',
                       style: 'margin-right: 10px; padding: 4px 8px; border-radius: 4px; border: 1px solid #ccc;' do
                  option 'All Departments', value: '', selected: params[:department_id].blank? ? 'selected' : nil
                  Department.order(:department_name).each do |dept|
                    selected = selected_department_id == dept.id.to_s ? 'selected' : nil
                    option dept.department_name, value: dept.id, selected:
                  end
                end
                input type: 'submit', value: 'Filter', class: 'button', style: 'margin-right: 10px;'
              end
              # Download button right
              link_to 'Download Instructor Report (CSV)',
                      url_for(controller: 'admin/dashboard', action: 'download_instructor_report',
                              department_id: (params[:department_id].presence || first_department&.id), format: :csv),
                      class: 'button',
                      style: 'background: #007bff; color: #fff; border-radius: 4px; padding: 6px 16px; text-decoration: none; font-weight: bold; border: none; margin-left: auto;'
            end

            departments = if params[:department_id].present?
                            Department.where(id: params[:department_id])
                          elsif first_department
                            Department.where(id: first_department.id)
                          else
                            Department.none
                          end

            departments.each do |department|
              panel "#{department.department_name} Department - Instructor Stats", style: 'width: 100%;' do
                instructors = department.admin_users.where(role: 'instructor')
                total_instructors = instructors.count
                if instructors.any?
                  # Table summary (counts only)
                  gender_categories = %w[Male Female]
                  achievement_categories = [
                    'Degree',
                    'Masters',
                    'PhD Candidate',
                    'PhD Holder (Doctor)',
                    'Assistant Professor',
                    'Associate Professor',
                    'Professor'
                  ]
                  employment_categories = %w[Part-time Full-time]
                  gender_counts = gender_categories.map { |g| [g, instructors.where(gender: g).count] }.to_h
                  achievement_counts = achievement_categories.map do |a|
                    [a, instructors.where(highest_level_educational_achievement: a).count]
                  end.to_h
                  employment_counts = employment_categories.map do |e|
                    [e, instructors.where(type_of_employment: e).count]
                  end.to_h

                  table_for [nil] do
                    column('Total Instructors') { total_instructors }
                    column('Male') { gender_counts['Male'] }
                    column('Female') { gender_counts['Female'] }
                    achievement_categories.each do |ach|
                      column(ach) { achievement_counts[ach] }
                    end
                    employment_categories.each do |emp|
                      column(emp) { employment_counts[emp] }
                    end
                  end

                  # Charts
                  div class: 'main-chart-container' do
                    div class: 'other-chart', id: "gender_chart_#{department.id}" do
                      pie_chart gender_counts, height: '250px', library: { title: { text: 'Gender Distribution' } }
                    end
                    div class: 'other-chart', id: "achievement_chart_#{department.id}" do
                      column_chart achievement_counts, height: '250px',
                                                       library: { title: { text: 'Highest Level Educational Achievement' } }
                    end
                    div class: 'other-chart', id: "employment_chart_#{department.id}" do
                      pie_chart employment_counts, height: '250px', library: { title: { text: 'Type of Employment' } }
                    end
                  end
                else
                  span 'No instructors in this department.'
                end
              end
            end
          end
        end
      end
    end

    hr
  end

  page_action :download_instructor_report, method: :get do
    require 'csv'
    gender_categories = %w[Male Female]
    achievement_categories = [
      'Degree',
      'Masters',
      'PhD Candidate',
      'PhD Holder (Doctor)',
      'Assistant Professor',
      'Associate Professor',
      'Professor'
    ]
    employment_categories = %w[Part-time Full-time]

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Hope Enterprise University College']
      csv << ['Department', 'Total Instructors', 'Male', 'Female'] + achievement_categories + employment_categories
      departments = if params[:department_id].present?
                      Department.where(id: params[:department_id])
                    else
                      Department.all
                    end
      departments.each do |department|
        instructors = department.admin_users.where(role: 'instructor')
        total_instructors = instructors.count
        gender_counts = gender_categories.map { |g| instructors.where(gender: g).count }
        achievement_counts = achievement_categories.map do |a|
          instructors.where(highest_level_educational_achievement: a).count
        end
        employment_counts = employment_categories.map { |e| instructors.where(type_of_employment: e).count }
        csv << [department.department_name, total_instructors] + gender_counts + achievement_counts + employment_counts
      end
    end
    send_data csv_data, filename: "instructor_report_#{Date.today}.csv"
  end
end
