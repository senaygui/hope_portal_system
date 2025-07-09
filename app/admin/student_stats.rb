# frozen_string_literal: true

ActiveAdmin.register_page 'StudentStats' do
  menu parent: 'student managment', priority: 11, label: 'Student Report'
  breadcrumb do
    ['Student ', 'Report']
  end

  content title: 'Student Report' do
    div class: 'student-status-widgets', style: 'display: flex; gap: 30px; margin-bottom: 30px;' do
      # Active students
      div class: 'widget-card',
          style: 'background: #e6f7ff; border-radius: 10px; padding: 24px 32px; min-width: 220px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05);' do
        h3 style: 'margin-bottom: 10px; color: #1890ff;' do
          'Active Students'
        end
        h1 style: 'font-size: 2.5em; margin: 0; color: #1890ff;' do
          Student.where(account_status: 'active').count
        end
      end
      # Suspended students
      div class: 'widget-card',
          style: 'background: #fffbe6; border-radius: 10px; padding: 24px 32px; min-width: 220px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05);' do
        h3 style: 'margin-bottom: 10px; color: #faad14;' do
          'Suspended Students'
        end
        h1 style: 'font-size: 2.5em; margin: 0; color: #faad14;' do
          Student.where(account_status: 'suspended').count
        end
      end
      # Graduated students
      div class: 'widget-card',
          style: 'background: #f6ffed; border-radius: 10px; padding: 24px 32px; min-width: 220px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05);' do
        h3 style: 'margin-bottom: 10px; color: #52c41a;' do
          'Graduated Students'
        end
        h1 style: 'font-size: 2.5em; margin: 0; color: #52c41a;' do
          Student.where(graduation_status: 'graduated').count
        end
      end
      # Withdrawals students
      div class: 'widget-card',
          style: 'background: #fff0f6; border-radius: 10px; padding: 24px 32px; min-width: 220px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05);' do
        h3 style: 'margin-bottom: 10px; color: #eb2f96;' do
          'Withdrawals'
        end
        h1 style: 'font-size: 2.5em; margin: 0; color: #eb2f96;' do
          Student.where(account_status: 'withdrawal').count
        end
      end
      # Total students
      div class: 'widget-card',
          style: 'background: #f0f5ff; border-radius: 10px; padding: 24px 32px; min-width: 220px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05);' do
        h3 style: 'margin-bottom: 10px; color: #2f54eb;' do
          'Total Students'
        end
        h1 style: 'font-size: 2.5em; margin: 0; color: #2f54eb;' do
          Student.count
        end
      end
    end

    # Department summary table and chart
    div style: 'display: flex; gap: 40px; align-items: flex-start; margin-bottom: 40px;' do
      panel 'Student Count by Department', style: 'width: 60%;' do
        table_for Department.order(:department_name) do
          column('Department') { |dept| dept.department_name }
          column('Active') { |dept| dept.students.where(account_status: 'active').count }
          column('Graduated') { |dept| dept.students.where(graduation_status: 'approved').count }
          column('Suspended') { |dept| dept.students.where(account_status: 'suspended').count }
          column('Withdrawals') { |dept| dept.students.where(account_status: 'withdrawal').count }
          column('Total') { |dept| dept.students.count }
        end
      end
      div style: 'width: 40%;' do
        column_chart Department.order(:department_name).map { |dept|
                       [dept.department_name, dept.students.count]
                     }, height: '350px', library: { title: { text: 'Total Students by Department' } }
        pie_chart Department.order(:department_name).map { |dept|
                    [dept.department_name, dept.students.where(account_status: 'active').count]
                  }, height: '350px', library: { title: { text: 'Active Students by Department' } }
      end
    end

    # Program summary table and chart
    div style: 'display: flex; gap: 40px; align-items: flex-start; margin-bottom: 40px;' do
      panel 'Student Count by Program', style: 'width: 60%;' do
        table_for Program.order(:program_name) do
          column('Program') { |prog| prog.program_name }
          column('Active') { |prog| prog.students.where(account_status: 'active').count }
          column('Graduated') { |prog| prog.students.where(graduation_status: 'approved').count }
          column('Suspended') { |prog| prog.students.where(account_status: 'suspended').count }
          column('Withdrawals') { |prog| prog.students.where(account_status: 'withdrawal').count }
          column('Total') { |prog| prog.students.count }
        end
      end
      div style: 'width: 40%;' do
        column_chart Program.order(:program_name).map { |prog|
                       [prog.program_name, prog.students.count]
                     }, height: '350px', library: { title: { text: 'Total Students by Program' } }
        pie_chart Program.order(:program_name).map { |prog|
                    [prog.program_name, prog.students.where(account_status: 'active').count]
                  }, height: '350px', library: { title: { text: 'Active Students by Program' } }
      end
    end

    # Active students by program, gender, batch, year
    div style: 'display: flex; gap: 40px; align-items: flex-start; margin-bottom: 40px;' do
      panel 'Active Students by Program, Gender, Batch, Year', style: 'width: 60%;' do
        table_for Program.order(:program_name) do
          column('Program') { |prog| prog.program_name }
          column('Gender') do |prog|
            male = prog.students.where(account_status: 'active', gender: 'Male').count
            female = prog.students.where(account_status: 'active', gender: 'Female').count
            "Male: #{male}, Female: #{female}"
          end
          column('Year & Semester') do |prog|
            prog.students.where(account_status: 'active').group(:year, :semester).count.map do |(year, sem), count|
              "Year #{year}, Semester #{sem}: #{count}"
            end.join('<br/>').html_safe
          end
          column('Total Active') { |prog| prog.students.where(account_status: 'active').count }
        end
      end
      div style: 'width: 40%;' do
        # Gender chart for all programs
        pie_chart [
          ['Male', Student.where(account_status: 'active', gender: 'Male').count],
          ['Female', Student.where(account_status: 'active', gender: 'Female').count]
        ], height: '180px', library: { title: { text: 'Active Students by Gender' } }
        # Batch chart for all programs
        column_chart Student.where(account_status: 'active').group(:batch).count, height: '180px',
                                                                                  library: { title: { text: 'Active Students by Batch' } }
        # Year chart for all programs
        column_chart Student.where(account_status: 'active').group(:year).count, height: '180px',
                                                                                 library: { title: { text: 'Active Students by Year' } }
      end
    end
  end
end
