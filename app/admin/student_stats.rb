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

    # Department summary table
    panel 'Student Count by Department', style: 'width: 100%; margin-bottom: 30px;' do
      table_for Department.order(:department_name) do
        column('Department') { |dept| dept.department_name }
        column('Active') { |dept| dept.students.where(account_status: 'active').count }
        column('Graduated') { |dept| dept.students.where(graduation_status: 'graduated').count }
        column('Suspended') { |dept| dept.students.where(account_status: 'suspended').count }
        column('Withdrawals') { |dept| dept.students.where(account_status: 'withdrawal').count }
        column('Total') { |dept| dept.students.count }
      end
    end

    # Program summary table
    panel 'Student Count by Program', style: 'width: 100%;' do
      table_for Program.order(:program_name) do
        column('Program') { |prog| prog.program_name }
        column('Department') { |prog| prog.department&.department_name }
        column('Active') { |prog| prog.students.where(account_status: 'active').count }
        column('Graduated') { |prog| prog.students.where(graduation_status: 'graduated').count }
        column('Suspended') { |prog| prog.students.where(account_status: 'suspended').count }
        column('Withdrawals') { |prog| prog.students.where(account_status: 'withdrawal').count }
        column('Total') { |prog| prog.students.count }
      end
    end

    # Active students by program, gender, batch, year, semester
    panel 'Active Students by Program, Gender, Batch, Year, Semester', style: 'width: 100%; margin-top: 30px;' do
      table_for Program.order(:program_name) do
        column('Program') { |prog| prog.program_name }
        column('Department') { |prog| prog.department&.department_name }
        column('Gender') do |prog|
          male = prog.students.where(account_status: 'active', gender: 'Male').count
          female = prog.students.where(account_status: 'active', gender: 'Female').count
          "Male: #{male}, Female: #{female}"
        end
        column('Batch') do |prog|
          prog.students.where(account_status: 'active').group(:batch).count.map do |batch, count|
            "#{batch}: #{count}"
          end.join(', ')
        end
        column('Year') do |prog|
          prog.students.where(account_status: 'active').group(:year).count.map do |year, count|
            "Year #{year}: #{count}"
          end.join(', ')
        end
        column('Semester') do |prog|
          prog.students.where(account_status: 'active').group(:semester).count.map do |sem, count|
            "Semester #{sem}: #{count}"
          end.join(', ')
        end
        column('Total Active') { |prog| prog.students.where(account_status: 'active').count }
      end
    end
  end
end
