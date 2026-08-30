class Reply < ApplicationRecord
  belongs_to :inquiry
  belongs_to :staff

  validates :body, presence: true
end
