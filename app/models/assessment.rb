class Assessment < ApplicationRecord
  # #vaildations
  # validate :limit_assessment_result
  # #associations
  belongs_to :student_grade
  belongs_to :student, optional: true
  belongs_to :course, optional: true
  belongs_to :assessment_plan, optional: true
  has_many :grade_changes
  has_many :makeup_exams
  has_many :assessment_results
  belongs_to :admin_user, optional: true
  # belongs_to :approved_by_instructor, class_name: 'AdminUser', optional: true
  # belongs_to :approved_by_head, class_name: 'AdminUser', optional: true

  # delegate :first_name, :middle_name, :last_name, to: :student, prefix: true
  # delegate :course_title, to: :course
  # delegate :section_id, to: :student, prefix: true

  # jsonb_accessor :result, value: [array: true, default: []]
  # jsonb_accessor :result, value: [array: true, default: []]

  # scope :assessment_by_instructor, -> { where('status = ?', 0) }
  # scope :approved_by_instructor, -> { where('status = ?', 1) }
  # scope :approved_by_head, -> { where('status = ?', 2) }
  # scope :incomplete_student, -> { where(status: 4) }
  # scope :graded, -> { where(status: 5) }

  # #  if self.admin_user.role.present?
  # enum status: {
  #   initial: 0,
  #   approved_by_instructor: 1,
  #   approved_by_head: 2,
  #   approved_by_dean: 3,
  #   incomplete: 4,
  #   final_grade: 5
  # }

  # def self.get_letter_grade(total)
  #   if total <= 100.00 && total >= 90.00
  #     ['A+', 4]
  #   elsif total <= 89.00 && total >= 83.00
  #     ['A', 4]
  #   elsif total <= 82.00 && total >= 80.00
  #     ['A-', 3.75]
  #   elsif total <= 79.00 && total >= 75.00
  #     ['B+', 3.5]
  #   elsif total <= 74.00 && total >= 68.00
  #     ['B', 3]
  #   elsif total <= 67.00 && total >= 65.00
  #     ['B-', 2.75]
  #   elsif total <= 64.00 && total >= 60.00
  #     ['C+', 2.5]
  #   elsif total <= 59.00 && total >= 50.00
  #     ['C', 2]
  #   elsif total <= 49.00 && total >= 45.00
  #     ['C-', 1.75]
  #   elsif total <= 44.00 && total >= 40.00
  #     ['D', 1.75]
  #   else
  #     ['F', 0]
  #   end
  # end

  # def self.total_mark(mark)
  #   total = 0.0
  #   mark.each do |m|
  #     total += m.last.to_f
  #   end
  #   total
  # end

  # def self.csv_columns_for_course(course_id)
  #   assessments = Assessment.where(course_id: course_id)
  #   assessments.map(&:value).map(&:keys).flatten.uniq
  # end

  # private

  # def limit_assessment_result
  #   errors[:result] << 'The assessment result reached the maximum value' if result > assessment_plan.assessment_weight
  # end
end
