# frozen_string_literal: true

require 'rails_helper'
# WebDrivers Gem
# https://github.com/titusfortner/webdrivers
#
# Official Guides about System Testing
# https://api.rubyonrails.org/v5.2/classes/ActionDispatch/SystemTestCase.html

RSpec.describe 'Short Urls', type: :system do
  before(js: true) do
    driven_by :selenium, using: :chrome
    # If using Firefox
    # driven_by :selenium, using: :firefox
    #
    # If running on a virtual machine or similar that does not have a UI, use
    # a headless driver
    # driven_by :selenium, using: :headless_chrome
    # driven_by :selenium, using: :headless_firefox
  end

  describe 'index' do
    it 'shows a list of short urls' do
      visit root_path
      expect(page).to have_text('HeyURL!')
    end
  end

  describe 'show' do
    it 'shows a panel of stats for a given short url' do
      visit url_path('ABCDE')
      expect(page).to have_text("The page you were looking for doesn't exist.")
    end

    context 'when not found' do
      it 'shows a 404 page' do
        visit url_path('NOTFOUND')
        expect(page).to have_text("The page you were looking for doesn't exist.")
      end
    end

    context 'when url exists' do
      it 'shows details page' do
        url = FactoryBot.create(:url)

        visit url_path(url.short_url)
        expect(page).to have_text(url.short_url)
        expect(page).to have_text("Original URL: #{url.original_url}")
      end
    end
  end

  describe 'create' do
    context 'when url is valid' do
      it 'creates the short url' do
        visit '/'
        build_url = FactoryBot.build(:url)
        before_count = Url.count
        find_field('url_original_url').set(build_url.original_url)
        expect{
          click_button("Shorten URL")
        }.to change(Url, :count).by(1)
        expect(page).to have_text(build_url.original_url)
        # add more expections
      end

      it 'redirects to the home page' do
        visit '/'
        build_url = FactoryBot.build(:url)
        before_count = Url.count
        find_field('url_original_url').set(build_url.original_url)
        click_button("Shorten URL")
        expect(page).to have_text('HeyURL!')
      end
    end

    context 'when url is invalid' do
      it 'does not create the short url and shows a message' do
        visit '/'
        visit '/'
        build_url = FactoryBot.build(:url, original_url: 'thisisrandomtext')
        before_count = Url.count
        find_field('url_original_url').set(build_url.original_url)
        click_button("Shorten URL")
        expect(page).to have_text('Original url is invalid')
      end

      it 'redirects to the home page' do
        visit '/'
        build_url = FactoryBot.build(:url, original_url: 'thisisrandomtext')
        before_count = Url.count
        find_field('url_original_url').set(build_url.original_url)
        click_button("Shorten URL")
        expect(page).to have_text('HeyURL!')
      end
    end
  end

  describe 'visit' do
    it 'redirects the user to the original url' do
      url = FactoryBot.create(:url)
      visit visit_path(url.short_url)
      expect(page.current_url).to eq(url.original_url)
    end

    it 'Increment url clicks count' do
      url = FactoryBot.create(:url)
      expect{
        visit visit_path(url.short_url)
      }.to change(Click, :count).by(1)
      url.reload
      expect(url.clicks_count).to eq(1)
    end

    context 'when not found' do
      it 'shows a 404 page' do
        visit visit_path('NOTFOUND')
        expect(page).to have_text("The page you were looking for doesn't exist.")
      end
    end
  end
end
