class Curriculum < ApplicationRecord

	##validations
   validates :curriculum_title, :presence => true, uniqueness: true
	 validates :batch, :presence => true
	 validates :curriculum_version, :presence => true, uniqueness: true
	 validates :curriculum_active_date, :presence => true
	##associations
	  belongs_to :program
	  has_many :courses, dependent: :destroy
	  has_many :grade_systems, dependent: :destroy

	  has_many :uneditable_courses, dependent: :destroy
	  has_one :uneditable_grade_system, dependent: :destroy
	  
	  accepts_nested_attributes_for :courses, reject_if: :all_blank, allow_destroy: true
	  accepts_nested_attributes_for :grade_systems, allow_destroy: true

	  after_commit :copy_to_uneditable_curriculum, on: :create


	  private

	 # def copy_to_uneditable_curriculum
	#	uneditable_curriculum = UneditableCurriculum.create!(
	#	  program_id: program_id,
	#	  curriculum_title: curriculum_title,
	#	  curriculum_version: curriculum_version,
	#	  total_course: total_course,
	#	  total_ects: total_ects,
	#	  total_credit_hour: total_credit_hour,
	#	  active_status: active_status,
	#	  curriculum_active_date: curriculum_active_date,
	#	  depreciation_date: depreciation_date,
	#	  created_by: created_by,
	#	  last_updated_by: last_updated_by
	#	)
	#
	#	courses.each do |course|
	#		Rails.logger.info "Copying course: #{course.course_title}"
#
	#	  UneditableCourse.create!(
	#		uneditable_curriculum_id: uneditable_curriculum.id,
	#		curriculum_id: course.curriculum_id,
	#		course_module_id: course.course_module_id,
	#		program_id: course.program_id,
	#		course_title: course.course_title,
	#		course_code: course.course_code,
	#		course_description: course.course_description,
	#		year: course.year,
	#		semester: course.semester,
	#		course_starting_date: course.course_starting_date,
	#		course_ending_date: course.course_ending_date,
	#		credit_hour: course.credit_hour,
	#		lecture_hour: course.lecture_hour,
	#		lab_hour: course.lab_hour,
	#		ects: course.ects,
	#		created_by: course.created_by,
	#		last_updated_by: course.last_updated_by
	#	  )
	#	end
	 # end

	 def copy_to_uneditable_curriculum
		# Create an uneditable curriculum
		uneditable_curriculum = UneditableCurriculum.create!(
		  program_id: program_id,
		  curriculum_title: curriculum_title,
		  curriculum_version: curriculum_version,
		  total_course: total_course,
		  total_ects: total_ects,
		  total_credit_hour: total_credit_hour,
		  active_status: active_status,
		  curriculum_active_date: curriculum_active_date,
		  depreciation_date: depreciation_date,
		  created_by: created_by,
		  last_updated_by: last_updated_by
		)
	
		# Copy courses
		courses.each do |course|
		  Rails.logger.info "Copying course: #{course.course_title}"
		  UneditableCourse.create!(
			uneditable_curriculum_id: uneditable_curriculum.id,
			curriculum_id: course.curriculum_id,
			course_module_id: course.course_module_id,
			program_id: course.program_id,
			course_title: course.course_title,
			course_code: course.course_code,
			course_description: course.course_description,
			year: course.year,
			semester: course.semester,
			course_starting_date: course.course_starting_date,
			course_ending_date: course.course_ending_date,
			credit_hour: course.credit_hour,
			lecture_hour: course.lecture_hour,
			lab_hour: course.lab_hour,
			ects: course.ects,
			created_by: course.created_by,
			last_updated_by: course.last_updated_by
		  )
		end
	
		# Copy grade system (if exists)
		if grade_systems
			grade_systems.each do |grade_system|
				UneditableGradeSystem.create!(
				  uneditable_curriculum_id: uneditable_curriculum.id,
				  program_id: program_id,
				  curriculum_id: grade_system.curriculum_id,
				  min_cgpa_value_to_pass: grade_system.min_cgpa_value_to_pass,
				  min_cgpa_value_to_graduate: grade_system.min_cgpa_value_to_graduate,
				  remark: grade_system.remark,
				  created_by: grade_system.created_by,
				  updated_by: grade_system.updated_by,
				  study_level: grade_system.study_level
				)
			  end
			  
	
		  # Copy grades
		  if grade_systems.any?
			first_grade_system = grade_systems.first
			first_grade_system.grades.each do |grade|
			  UneditableGrade.create!(
				grade_system_id: first_grade_system.id,
				letter_grade: grade.letter_grade,
				grade_point: grade.grade_point,
				min_row_mark: grade.min_row_mark,
				max_row_mark: grade.max_row_mark,
				created_by: grade.created_by,
				updated_by: grade.updated_by
			  )
			end
		  end
		  
	
		  # Copy academic statuses
		  if grade_systems.any?
			first_grade_system = grade_systems.first
			first_grade_system.academic_statuses.each do |status|
			  UneditableAcademicStatus.create!(
				grade_system_id: first_grade_system.id,
				status: status.status,
				min_value: status.min_value,
				max_value: status.max_value,
				created_by: status.created_by,
				updated_by: status.updated_by
			  )
			end
		  end
		  
		end
	  end
end
