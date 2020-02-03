class DeliveryMessage < ApplicationRecord

  belongs_to :calendar

  scope :with_calendar, ->(calendar) { where(calendar_id: calendar.id) }

end
