class ReadmissionsController < ApplicationController
  before_action :authenticate_student! # Assuming you have authentication in place

  def index
    @readmissions = current_student.readmissions
  end

  def new
    @readmission = Readmission.new
  end

  def create
    @readmission = current_student.readmissions.build(readmission_params)
    if @readmission.save
      redirect_to payment_readmission_path(@readmission),
                  notice: 'Readmission request submitted successfully. Please proceed to payment.'
    else
      puts "Validation errors: #{@readmission.errors.full_messages}"
      flash.now[:error] = @readmission.errors.full_messages.to_sentence
      render :new
    end
  end

  def payment
    @readmission = Readmission.find(params[:id])

    study_level = current_student.study_level.strip.downcase
    admission_type = current_student.admission_type.strip.downcase

    puts "Student Study Level: #{study_level}"
    puts "Student Admission Type: #{admission_type}"
    puts "Current Student Info: #{current_student.inspect}"

    @college_payment = CollegePayment.where(
      'LOWER(TRIM(study_level)) = ? AND LOWER(TRIM(admission_type)) = ? ',
      study_level,
      admission_type
    ).first

    if @college_payment.nil?
      puts 'No matching CollegePayment found.'
    else
      puts "Matching CollegePayment found: #{@college_payment.inspect}"
    end
  end

  def verify
    @readmission = Readmission.find(params[:id])
    @readmission.update(verified: true)
    create_payment(@readmission)
  end

  def update
    @readmission = Readmission.find(params[:id])

    if @readmission.update(readmission_params)
      redirect_to root_path, notice: 'Receipt uploaded successfully.'
    else
      render :payment, status: :unprocessable_entity
    end
  end

  private

  def readmission_params
    params.require(:readmission).permit(:last_earned_cgpa, :readmission_semester, :readmission_year,
                                        :reason_for_withdrawal, :comments, :program_id, :department_id, :section_id, :academic_calendar_id, :receipt)
  end
end
