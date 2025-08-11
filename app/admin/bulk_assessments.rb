ActiveAdmin.register_page 'BulkAssessments' do
  # Visible to instructors and admins
  menu parent: 'Grade', priority: 5, if: proc { %w[instructor admin].include?(current_admin_user.role) }

  # POST /admin/bulkassessments/submit
  page_action :submit, method: :post do
    # New payload shape: cells[] = { assessment_id, assessment_plan_id, student_grade_id, result }
    cells = Array(params[:cells])
    # Backward compatibility (older payload): assessments[assessment_id][result]
    assessments_by_id = params[:assessments] || {}
    student_grade_ids = Array(params[:student_grade_ids]).uniq
    commit_action = (params[:commit] || '').to_s

    ActiveRecord::Base.transaction do
      touched_sg_ids = []

      # Handle new cells array, creating or updating assessments as needed
      cells.each do |cell|
        next if cell.blank?
        sg_id = cell[:student_grade_id] || cell['student_grade_id']
        ap_id = cell[:assessment_plan_id] || cell['assessment_plan_id']
        a_id  = cell[:assessment_id] || cell['assessment_id']
        raw   = cell[:result] || cell['result']
        value = begin
          Float(raw)
        rescue StandardError
          nil
        end
        next if sg_id.blank? || ap_id.blank?

        # Disallow edits for submitted student grades
        sg = StudentGrade.find_by(id: sg_id)
        if sg.nil?
          raise ActiveRecord::RecordNotFound, 'Student grade not found'
        end
        if sg.instructor_submit_status.to_s.downcase == 'submitted'
          raise StandardError, 'Cannot edit a submitted student grade.'
        end

        # Enforce per-plan weight limit (applies whether creating or updating)
        plan = AssessmentPlan.find(ap_id)
        if value.present? && plan && value.to_f > plan.assessment_weight.to_f
          raise StandardError, "Entered value (#{value}) exceeds weight (#{plan.assessment_weight}) for #{plan.assessment_title}."
        end

        a = if a_id.present?
              Assessment.find_by(id: a_id)
            else
              Assessment.find_or_initialize_by(student_grade_id: sg_id, assessment_plan_id: ap_id)
            end
        next unless a

        a.student_grade_id ||= sg_id
        a.assessment_plan_id ||= ap_id
        a.updated_by = current_admin_user.name.full
        a.result = value
        a.save!
        touched_sg_ids << sg_id
      end

      # Backward compatibility path
      assessments_by_id.each do |assessment_id, attrs|
        a = Assessment.find_by(id: assessment_id)
        next unless a
        # Disallow edits for submitted student grades
        if a.student_grade&.instructor_submit_status.to_s.downcase == 'submitted'
          raise StandardError, 'Cannot edit a submitted student grade.'
        end

        # Enforce per-plan weight limit for legacy payload
        val = attrs[:result]
        plan = a.assessment_plan
        if val.present? && plan && val.to_f > plan.assessment_weight.to_f
          raise StandardError, "Entered value (#{val}) exceeds weight (#{plan.assessment_weight}) for #{plan.assessment_title}."
        end

        a.update!(result: val, updated_by: current_admin_user.name.full)
        touched_sg_ids << a.student_grade_id
      end

      # Persist submission metadata and recompute assesment_total per student grade
      affected_ids = (student_grade_ids + touched_sg_ids).uniq
      StudentGrade.where(id: affected_ids).find_each do |sg|
        total = sg.assessments.sum(:result).to_f
        if total > 100.0
          raise StandardError, 'Total assessment cannot exceed 100.'
        end
        attrs = {
          assesment_total: total,
          instructor_name: current_admin_user.name.full
        }
        # Only on explicit Submit Final do we mark as submitted
        if commit_action == 'Submit Final'
          attrs[:instructor_submit_status] = 'Submitted'
        end
        sg.update!(attrs)
      end
    end

    redirect_to admin_bulkassessments_path(assignment_id: params[:assignment_id]),
                notice: 'Assessments saved and submitted.'
  rescue StandardError => e
    redirect_back fallback_location: admin_bulkassessments_path, alert: e.message
  end

  # GET /admin/bulkassessments
  content title: 'Bulk Assessments' do
    assignments = if current_admin_user.role == 'admin'
                    CourseInstructor.all
                  else
                    CourseInstructor.where(admin_user_id: current_admin_user.id)
                  end
                  .includes(:course, :section, :academic_calendar)

    panel 'Select Assignment' do
      if assignments.blank?
        para 'No assignments found for your account.'
      else
        div do
          form action: admin_bulkassessments_path, class: "assignment_selector", method: :get do
            text_node select_tag(
              :assignment_id,
              options_for_select(assignments.map do |ci|
                label = [
                  "Course: #{ci.course&.course_title}",
                  (ci.section&.section_full_name || 'No Section'),
                  "Year: #{ci.year}",
                  "Semester: #{ci.semester}",
                  "Calendar Year: #{ci.academic_calendar&.calender_year}"
                ].compact.join(' | ')
                [label, ci.id]
              end, params[:assignment_id]),
              include_blank: 'Choose assignment',
              onchange: 'this.form.submit()'
            )
          end
        end
      end
    end

    if params[:assignment_id].present?
      ci = assignments.find_by(id: params[:assignment_id])
      if ci.nil?
        para 'Assignment not found or not accessible.'
        next
      end

      # Build consistent assessment plan columns for the selected course
      assessment_plans = ci.course.assessment_plans.order(final_exam: :desc, assessment_title: :asc)

      student_grades = StudentGrade
                         .joins(:course_registration)
                         .where(course_registrations: {
                                  course_id: ci.course_id,
                                  section_id: ci.section_id,
                                  academic_calendar_id: ci.academic_calendar_id,
                                  year: ci.section.year,
                                  semester: ci.section.semester
                                })
                         .includes(:student, :assessments)
                         .order('students.first_name ASC')

      panel "Enter Results for #{ci.course.course_title} (#{student_grades.size} students)" do
        div do
          form action: admin_bulkassessments_submit_path, method: :post, id: 'bulk-assessments-form' do
            # CSRF token
            text_node hidden_field_tag(:authenticity_token, form_authenticity_token)
            text_node hidden_field_tag(:assignment_id, ci.id)

            # styles for scrollable table and sticky total column
            text_node content_tag(:style, <<~CSS)
              .bulk-table-wrapper { overflow-x: auto; }
              .bulk-assessments-table th.sticky-total, .bulk-assessments-table td.sticky-total {
                position: sticky; right: 0; background: #fff; z-index: 2; box-shadow: -2px 0 0 rgba(0,0,0,0.05);
              }
              input.invalid-weight {
                border-color: #e74c3c !important;
                background-color: #fdecea !important;
              }
            CSS

            div class: 'bulk-table-wrapper' do
            table class: 'index_table bulk-assessments-table' do
              thead do
                tr do
                  th 'Student'
                  th 'Student ID'
                  assessment_plans.each do |ap|
                    th "#{ap.assessment_title} (#{ap.assessment_weight} %)"
                  end
                  th 'Total (100%)', class: 'sticky-total'
                end
              end
              tbody do
                student_grades.each do |sg|
                  text_node hidden_field_tag 'student_grade_ids[]', sg.id

                  tr data: { student_grade_id: sg.id } do
                    td sg.student.full_name
                    td sg.student.student_id

                    # Ensure every row shows inputs for each plan
                    assessment_plans.each do |ap|
                      a = sg.assessments.detect { |x| x.assessment_plan_id == ap.id }
                      value = a&.result
                      td do
                        if sg.instructor_submit_status.to_s.downcase == 'submitted'
                          # Readonly display when submitted
                          text_node content_tag(:span, value.to_f)
                        else
                          # Hidden metadata for server-side processing
                          text_node hidden_field_tag('cells[][assessment_id]', a&.id)
                          text_node hidden_field_tag('cells[][assessment_plan_id]', ap.id)
                          text_node hidden_field_tag('cells[][student_grade_id]', sg.id)
                          # The value input
                          text_node number_field_tag(
                            'cells[][result]',
                            value,
                            step: 'any', min: 0, max: ap.assessment_weight,
                            class: 'assessment-result',
                            data: { role: 'assessment-input', weight: ap.assessment_weight, assessment_plan_id: ap.id }
                          )
                        end
                      end
                    end

                    # Total cell (visible + hidden field for submission)
                    td class: 'sticky-total' do
                      total_value = begin
                        sg.assessments.sum(:result).to_f
                      rescue StandardError
                        0
                      end
                      text_node content_tag(:span, total_value,
                                             id: "assessment-total-#{sg.id}",
                                             data: { role: 'assessment-total', student_grade_id: sg.id })
                      text_node hidden_field_tag(
                        "student_grade_totals[#{sg.id}]",
                        total_value,
                        id: "assessment-total-input-#{sg.id}",
                        data: { role: 'assessment-total-input', student_grade_id: sg.id }
                      )
                    end
                  end
                end
              end
            end

            end # bulk-table-wrapper

            div style: 'margin-top:12px; display:flex; gap:8px;' do
              # Save button (does not change status)
              text_node submit_tag 'Save', class: 'button', id: 'bulk-save'
              # Submit Final button (locks by marking submitted)
              text_node submit_tag 'Submit Final', class: 'button', id: 'bulk-submit'
            end
          end
        end

        # Inline JS for realtime totals
        script do
          raw <<~JS
            (function(){
              function toNumber(v){
                if (typeof v === 'string') v = v.replace(',', '.');
                var n = parseFloat(v);
                return isNaN(n) ? 0.0 : n;
              }

              function recalcRowTotal(row){
                var inputs = row.querySelectorAll('input[data-role="assessment-input"]');
                var sum = 0.0;
                inputs.forEach(function(inp){
                  var val = toNumber(inp.value);
                  sum += val;
                  // per-input weight validation
                  var max = toNumber(inp.dataset.weight || '0');
                  if (max && val > max) {
                    inp.classList.add('invalid-weight');
                    inp.title = 'Value exceeds assessment weight (' + max + ')';
                  } else {
                    inp.classList.remove('invalid-weight');
                    inp.removeAttribute('title');
                  }
                });
                var totalEl = row.querySelector('span[data-role="assessment-total"]');
                if (totalEl) totalEl.textContent = sum.toFixed(2);
                var totalInput = row.querySelector('input[data-role="assessment-total-input"]');
                if (totalInput) totalInput.value = sum.toFixed(2);
                // flag if > 100
                if (sum > 100.0) {
                  row.classList.add('invalid-total');
                  if (totalEl) totalEl.style.color = 'red';
                } else {
                  row.classList.remove('invalid-total');
                  if (totalEl) totalEl.style.color = '';
                }
                return sum;
              }

              function updateSubmitState(){
                var form = document.getElementById('bulk-assessments-form');
                if (!form) return;
                var anyInvalid = false;
                document.querySelectorAll('tr[data-student-grade-id]').forEach(function(row){
                  // ensure total up-to-date
                  var sum = recalcRowTotal(row);
                  if (sum > 100.0) anyInvalid = true;
                });
                // disable as well if any input exceeds its weight
                if (document.querySelector('input.invalid-weight')) anyInvalid = true;
                var btn = document.getElementById('bulk-submit');
                if (btn) btn.disabled = anyInvalid;
                var saveBtn = document.getElementById('bulk-save');
                if (saveBtn) saveBtn.disabled = anyInvalid;
              }

              document.addEventListener('input', function(e) {
                var el = e.target;
                if (el && el.dataset && el.dataset.role === 'assessment-input') {
                  var row = el.closest('tr[data-student-grade-id]');
                  if (row) recalcRowTotal(row);
                  updateSubmitState();
                }
              });

              // Recalc while typing (for browsers that don't fire 'input' consistently on number fields)
              document.addEventListener('keyup', function(e){
                var el = e.target;
                if (el && el.dataset && el.dataset.role === 'assessment-input') {
                  var row = el.closest('tr[data-student-grade-id]');
                  if (row) recalcRowTotal(row);
                  updateSubmitState();
                }
              });

              document.addEventListener('change', function(e) {
                var el = e.target;
                if (el && el.dataset && el.dataset.role === 'assessment-input') {
                  var row = el.closest('tr[data-student-grade-id]');
                  if (row) recalcRowTotal(row);
                  updateSubmitState();
                }
              });

              // Update total when focus leaves an input (more reliable than change in some browsers)
              document.addEventListener('focusout', function(e){
                var el = e.target;
                if (el && el.dataset && el.dataset.role === 'assessment-input') {
                  var row = el.closest('tr[data-student-grade-id]');
                  if (row) recalcRowTotal(row);
                  updateSubmitState();
                }
              }, true);

              document.addEventListener('change', function(e) {
                var el = e.target;
                if (el && el.dataset && el.dataset.role === 'assessment-input') {
                  var row = el.closest('tr[data-student-grade-id]');
                  if (row) recalcRowTotal(row);
                }
              });

              function initTotals(){
                document.querySelectorAll('tr[data-student-grade-id]').forEach(function(row){
                  recalcRowTotal(row);
                });
                updateSubmitState();
              }

              // Initialize on Turbo and on initial DOM ready
              document.addEventListener('DOMContentLoaded', initTotals);
              document.addEventListener('turbo:load', initTotals);

              // In case neither fires (AA PJAX), attempt immediate init
              initTotals();

              // Block form submission client-side when invalid
              var form = document.getElementById('bulk-assessments-form');
              if (form) {
                form.addEventListener('submit', function(e){
                  updateSubmitState();
                  var anyInvalid = document.querySelector('tr.invalid-total') || document.querySelector('input.invalid-weight');
                  if (anyInvalid) {
                    e.preventDefault();
                    var msg = 'Please fix validation errors: ';
                    if (document.querySelector('tr.invalid-total')) msg += 'Total cannot exceed 100. ';
                    if (document.querySelector('input.invalid-weight')) msg += 'Some values exceed assessment weights.';
                    alert(msg);
                  }
                });
              }
            })();
          JS
        end
      end
    else
      para 'Please choose an assignment to begin.'
    end
  end
end
