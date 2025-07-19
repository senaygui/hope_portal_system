class AddCourse < ApplicationRecord
  belongs_to :student
  belongs_to :course
  belongs_to :department
  belongs_to :section, optional: true
  belongs_to :dropcourse, optional: true
 ##todo add cr x tution_per_cr and add it to total ammount 
  enum status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    taken: 4
  }
end
