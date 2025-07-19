class ExamScheduleWithFile < ApplicationRecord
  has_one_attached :exam_schedule_file
  validates :name, presence: true
  validates :exam_schedule_file, presence: true
  validate :exam_schedule_file_type

  private

  def exam_schedule_file_type
    return unless exam_schedule_file.attached?

    acceptable_types = ['application/pdf'] + ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/bmp',
                                              'image/tiff', 'image/webp']
    unless acceptable_types.include?(exam_schedule_file.content_type)
      errors.add(:exam_schedule_file, 'must be a PDF or image file')
    end
  end
end
