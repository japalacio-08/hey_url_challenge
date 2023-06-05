# frozen_string_literal: true

class Url < ApplicationRecord
  # scope :latest, -> {}
  SHORT_URL_DEFAULT_LENGTH = 5

  attr_readonly :short_url

  validates :original_url, presence: true, format: /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
  validates :short_url, presence: true, on: :create

  before_validation :populate_http_https
  before_validation :generate_short_url
  has_many :clicks

  private

  def generate_short_url
    self.short_url = unique_token
  end

  def unique_token
    token = SecureRandom.alphanumeric(SHORT_URL_DEFAULT_LENGTH).upcase

    return unique_token if Url.find_by(short_url: token).present?

    token
  end

  # For Mitigate http://http://<the other text> issue
  def populate_http_https
    return if self.original_url.blank? || url_protocol_present?
    self.original_url = "http://#{self.original_url}"
  end

  def url_protocol_present?
    self.original_url[/\Ahttp:\/\//] || self.original_url[/\Ahttps:\/\//]
  end
end
