class ClassSchedulesController < ApplicationController
    before_action :authenticate_student! # Assuming you have a method to authenticate the student

    before_action :set_class_schedule, only: [:show, :edit, :update, :destroy]
    before_action :set_student
    
    
    def index
      @class_schedules = ClassSchedule.where(program_id: current_student.program)
    end
  
    def show
    end
  
    def new
      @class_schedule = ClassSchedule.new
    end
  
    def create
      @class_schedule = ClassSchedule.new(class_schedule_params)
      if @class_schedule.save
        redirect_to @class_schedule, notice: 'Class schedule was successfully created.'
      else
        render :new
      end
    end
  
    def edit
    end
  
    def update
      if @class_schedule.update(class_schedule_params)
        redirect_to @class_schedule, notice: 'Class schedule was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
      @class_schedule.destroy
      redirect_to class_schedules_url, notice: 'Class schedule was successfully destroyed.'
    end
    
    def class_schedules
      @class_schedules = ClassSchedule.for_student(current_student)
    end
  
    
    private
  
    def set_class_schedule
      @class_schedule = ClassSchedule.find(params[:id])
    end

    def set_student
      @student = current_student # Assuming current_student method returns the logged-in student

    end
  
    def class_schedule_params
      params.require(:class_schedule).permit(:course_id, :program_id, :section_id, :day_of_week, :start_time, :end_time, :classroom, :class_type, :instructor_name, :year, :semester)
    end
  end
  