class CourseRegistration < ApplicationRecord
  # after_create :add_invoice_item
  validate :check_prerequisites
  after_save :add_grade
  after_save :attribute_assignment
  after_save do
    add_course.taken! if add_course.present?
  end
  # #associations
  belongs_to :semester_registration
  belongs_to :department
  belongs_to :course
  has_many :invoice_items
  has_one :student_grade, dependent: :destroy
  belongs_to :student
  belongs_to :academic_calendar
  belongs_to :program
  # belongs_to :course_section, optional: true
  belongs_to :section, optional: true
  belongs_to :add_course, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :grade_changes, dependent: :destroy
  has_many :makeup_exams
  # validates_associated :student_grades

  enum drop_pending_status: {
     no_pending: 0,
     pending: 1
  }

  enum is_active: {
    no: 0,
    yes: 1
  }, _prefix: 'active'

  def get_academic_year
    "#{academic_year - 1}/#{academic_year}"
  end

  def self.get_course_per_student(student_ids)
    where(student_id: student_ids).includes(:student).includes(:course).includes(:student_grade)
  end

  def add_grade
    if section.present? && !student_grade.present?
      StudentGrade.create! do |student_grade|
        student_grade.course_registration_id = id
        student_grade.student_id = student.id
        student_grade.course_id = course.id
        student_grade.department_id = department.id
        student_grade.program_id = program.id
        student_grade.created_by = updated_by
        # student_grade.department_head_date_of_response = Time.now
      end
    end
  end

  private

  # def add_invoice_item
  # 	if (self.semester_registration.semester == 1) && (self.semester_registration.year == 1) && self.semester_registration.mode_of_payment.present? && self.semester_registration.invoices.last.nil?
  # 		InvoiceItem.create do |invoice_item|
  # 			invoice_item.invoice_id = self.semester_registration.invoice.id
  # 			invoice_item.course_registration_id = self.id

  # 			if self.semester_registration.mode_of_payment == "monthly"
  # 				course_price =  CollegePayment.where(study_level: self.study_level,admission_type: self.admission_type).first.tution_per_credit_hr * self.curriculum.credit_hour / 4
  # 			elsif self.semester_registration.mode_of_payment == "full"
  # 				course_price =  CollegePayment.where(study_level: self.study_level,admission_type: self.admission_type).first.tution_per_credit_hr * self.curriculum.credit_hour
  # 			elsif self.semester_registration.mode_of_payment == "half"
  # 				course_price =  CollegePayment.where(study_level: self.study_level,admission_type: self.admission_type).first.tution_per_credit_hr * self.curriculum.credit_hour / 2
  # 			end
  # 			invoice_item.price = course_price
  # 		end
  # 	end
  # end

  def check_prerequisites
    prerequisites = Prerequisite.where(course_id:)

    prerequisites.each do |prerequisite|
      prerequisite_course = prerequisite.prerequisite
      student_grade = StudentGrade.find_by(student_id:, course_id: prerequisite_course.id)

      if student_grade.nil? || student_grade.letter_grade == 'F'
        errors.add(:base, "You have not passed the prerequisite course #{prerequisite_course.course_title}.")
      end
    end
  end

  def attribute_assignment
    self[:section_id] = semester_registration.section.id if !section.present? && semester_registration.section.present? && !add_course_id.present?
  end
end
