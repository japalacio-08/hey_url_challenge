# frozen_string_literal: true

class Click < ApplicationRecord
  belongs_to :url

  validates :browser, presence: true
  validates :platform, presence: true

  after_create :increase_url_click_count

  def increase_url_click_count
    self.url.increment(:clicks_count).save!
  end
end
