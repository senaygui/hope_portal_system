class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :trackable
  has_person_name
  has_one_attached :photo, dependent: :destroy
  has_many :assessment_plans

    # attr_accessor :type_of_employment, :gender, :highest_level_educational_achievement

    # #validations
    # validates :username , :presence => true,:length => { :within => 2..50 }
    validates :first_name, presence: true, length: { within: 2..50 }
    validates :last_name, presence: true, length: { within: 1..50 }
    validates :role, presence: true
    validates :type_of_employment, :gender, :highest_level_educational_achievement, :department_id, presence: true, if: lambda {
                                                                                                                          role == 'instructor'
                                                                                                                        }
    # validates :photo, attached: true, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg']
  ## scope

    scope :recently_added, -> { where('created_at >= ?', 1.week.ago) }
    scope :total_users, -> { order('created_at DESC') }
    scope :admins, -> { where(role: 'admin') }
    scope :registrars, -> { where('role = ?', '%registrar%') }
    scope :finances, -> { where('role = ?', '%finance%') }
    scope :president, -> { where(role: 'president') }
    scope :vice_presidents, -> { where(role: 'vice president') }
    scope :quality_assurances, -> { where(role: 'quality assurance') }
    scope :deans, -> { where(role: 'dean') }
    scope :library, -> { where(role: 'library') }
    scope :department_heads, -> { where(role: 'department head') }
    scope :program_offices, -> { where(role: 'program office') }

    ## associations
      has_many :course_instructors
      has_many :notices
      belongs_to :department, optional: true
      belongs_to :faculty, optional: true

      def full_name
        [first_name, middle_name.presence, last_name.presence].compact.join(' ')
      end
end
