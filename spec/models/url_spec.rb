# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Url, type: :model do
  subject { described_class.new }

  describe 'validations' do
    it 'validates presence of original URL' do
      expect(subject.valid?).to eq(false)
    end

    it 'validates original URL is a valid URL' do
      subject.original_url = 'www.google.com'
      expect(subject.valid?).to eq(true)

      subject.original_url = 'thisisarandomtext'
      expect(subject.valid?).to eq(false)
    end

    it 'validates short URL is present' do
      subject.original_url = 'www.google.com'

      subject.save

      expect(subject.short_url).to_not be(nil)

      expect(subject.short_url.length).to be(5)
    end

    # add more tests
  end
end
