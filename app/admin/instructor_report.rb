# frozen_string_literal: true

ActiveAdmin.register_page 'InstructorReport' do
  menu parent: 'Department', priority: 11, label: 'Instructor Report'
  breadcrumb do
    ['Department ', 'Instructor Report']
  end

  content do
    tabs do
      tab 'Instructor statistics ' do
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
      tab 'Teaching Load' do
        instructors = AdminUser.where(role: 'instructor')
        course_instructors = CourseInstructor.includes(:course, :academic_calendar, :admin_user)

        # Group by instructor, year, semester, academic year
        teaching_loads = course_instructors.group_by(&:admin_user_id).transform_values do |assignments|
          assignments.group_by do |ci|
            [ci.year, ci.semester, ci.academic_calendar&.calender_year_in_gc]
          end.transform_values do |group|
            {
              credit_hours: group.sum { |ci| ci.course&.credit_hour.to_i },
              year: group.first.year,
              semester: group.first.semester,
              academic_year: group.first.academic_calendar&.calender_year_in_gc
            }
          end
        end

        div do
          text_node <<-HTML.html_safe
            <style>
              .teaching-load-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 24px;
              }
              .teaching-load-table th, .teaching-load-table td {
                padding: 10px 14px;
                border: 1px solid #e0e0e0;
                text-align: center;
              }
              .teaching-load-table th {
                background: #f5f5f5;
                color: #333;
                font-weight: bold;
              }
              .teaching-load-table tr:nth-child(even) {
                background: #fafbfc;
              }
              .teaching-load-table tr.overload {
                background: #fff3cd !important; /* light yellow for overload */
              }
            </style>
          HTML
        end

        panel 'Instructor Teaching Load by Academic Year and Semester' do
          table_html = <<-HTML
            <table class="teaching-load-table">
              <thead>
                <tr>
                  <th>Full Name</th>
                  <th>Academic Year</th>
                  <th>Year</th>
                  <th>Semester</th>
                  <th>Total Credit Hours</th>
                  <th>Overload</th>
                  <th>Overload By</th>
                </tr>
              </thead>
              <tbody>
          HTML

          instructors.each do |instructor|
            loads = teaching_loads[instructor.id] || {}
            load_values = loads.values
            load_count = load_values.size
            if load_count > 0
              load_values.each_with_index do |row, idx|
                overload = row[:credit_hours] > 12
                table_html += <<-ROW
                  <tr class="#{overload ? 'overload' : ''}">
                    #{idx == 0 ? "<td rowspan=\"#{load_count}\">#{instructor.first_name} #{instructor.last_name}</td>" : ''}
                    <td>#{row[:academic_year]}</td>
                    <td>#{row[:year]}</td>
                    <td>#{row[:semester]}</td>
                    <td>#{row[:credit_hours]}</td>
                    <td>#{overload ? 'Yes' : 'No'}</td>
                    <td>#{overload ? (row[:credit_hours] - 12) : 0}</td>
                  </tr>
                ROW
              end
            else
              table_html += <<-ROW
                <tr>
                  <td>#{instructor.first_name} #{instructor.last_name}</td>
                  <td colspan=\"6\"><em>No teaching assignment</em></td>
                </tr>
              ROW
            end
          end

          table_html += <<-HTML
              </tbody>
            </table>
          HTML

          div do
            text_node table_html.html_safe
          end
        end
      end
    end
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
