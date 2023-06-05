# frozen_string_literal: true

class UrlsController < ApplicationController
  before_action :set_url_by_short_url, only: %i[visit show]

  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.all
  end

  def create
    @url = Url.new(url_params)

    flash[:notice] = @url.errors.full_messages.to_sentence if !@url.save

    redirect_to urls_path
  end

  def last_10
    render json: Url.order('created_at DESC').first(10).to_json(include: %i[clicks])
  end

  def show
    # implement queries
    @daily_clicks = @url.clicks.order('DATE(created_at) DESC').group('DATE(created_at)').limit(10).pluck(['DATE(created_at)::text', 'count(DATE(created_at))'])

    @browsers_clicks = @url.clicks.group(:browser).pluck([:browser, 'COUNT(browser)'])

    @platform_clicks = @url.clicks.group(:platform).pluck([:platform, 'COUNT(platform)'])
  end

  def visit
    Click.create!(
      url_id: @url.id,
      browser: browser.name,
      platform: browser.platform.name
    )

    redirect_to @url.original_url
  end

  private

  def set_url_by_short_url
    url = params[:short_url].presence || params[:url]
    @url = Url.find_by(short_url: url)
    return not_found_method if @url.blank?
  end

  def url_params
    params.require(:url).permit(:original_url)
  end
end
