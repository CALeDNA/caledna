# frozen_string_literal: true

require 'rails_helper'

describe UserSubmission do
  context 'validation' do
    let(:attr) do
      { content: 'content', title: 'title', user_display_name: 'name',
        user: create(:user) }
    end
    let(:image) { './spec/fixtures/uploads/screenshot.png' }
    let(:large_image) { './spec/fixtures/uploads/large.jpg' }
    let(:csv) { './spec/fixtures/import_csv/dna_results_tabs.csv' }
    let(:url) { 'http://example.com' }

    it 'valid when required fields and media_url are present' do
      submission = build(:user_submission, attr.merge(media_url: url))

      expect(submission.valid?).to eq(true)
    end

    it 'valid when required fields and image are present' do
      file_upload = fixture_file_upload(image, 'image/png')
      submission = build(:user_submission, attr.merge(image: file_upload))
      submission.image.attach(io: File.open(image), filename: 'image.png',
                              content_type: 'image/png')

      expect(submission.valid?).to eq(true)
    end

    it 'invalid when image is too large' do
      file_upload = fixture_file_upload(large_image, 'image/png')
      submission = build(:user_submission, attr.merge(image: file_upload))
      submission.image.attach(io: File.open(large_image), filename: 'image.png',
                              content_type: 'image/png')
      submission.valid?

      message = ['Image must be under 10 MB.']
      expect(submission.errors.messages[:image]).to eq(message)
    end

    it 'valid when image is jpg or png' do
      file_upload = fixture_file_upload(image, 'image/png')
      submission = build(:user_submission, attr.merge(image: file_upload))
      %w[jpg jpeg png].each do |type|
        submission.image.attach(io: File.open(image), filename: "file.#{type}",
                                content_type: "image/#{type}")

        expect(submission.valid?).to eq(true)
      end
    end

    it 'invalid when image is not jpg or png' do
      file_upload = fixture_file_upload(csv, 'text/csv')
      submission = build(:user_submission, attr.merge(image: file_upload))
      submission.image.attach(io: File.open(csv), filename: 'file.csv',
                              content_type: 'text/csv')
      submission.valid?

      message = ['Image must be png, jpg, or jpeg.']
      expect(submission.errors.messages[:image]).to eq(message)
    end

    it 'valid when media url starts with http or https' do
      %w[http https].each do |type|
        url = "#{type}://example.com"
        submission = build(:user_submission, attr.merge(media_url: url))

        expect(submission.valid?).to eq(true)
      end
    end

    it 'invalid when media url does not start' do
      %w[example.com www.example.com].each do |url|
        submission = build(:user_submission, attr.merge(media_url: url))

        expect(submission.valid?).to eq(false)
      end
    end
  end
end
