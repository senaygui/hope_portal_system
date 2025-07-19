class ClassScheduleWithFile < ApplicationRecord
    has_one_attached :class_schedule_file
    validates :name, presence: true
    validates :class_schedule_file, presence: true
    validate :class_schedule_file_type

    private

    def class_schedule_file_type
      return unless class_schedule_file.attached?

      acceptable_types = ['application/pdf'] + ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/bmp',
                                                'image/tiff', 'image/webp']
      unless acceptable_types.include?(class_schedule_file.content_type)
        errors.add(:class_schedule_file, 'must be a PDF or image file')
      end
    end
end
