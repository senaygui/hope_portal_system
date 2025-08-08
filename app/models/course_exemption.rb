class CourseExemption < ApplicationRecord
  belongs_to :course, optional: true
  belongs_to :exemptible, polymorphic: true
end
