# frozen_string_literal: true

class ChapterFileSizeWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  def perform(chapter_file_id)
    chapter_file = ChapterFile.find(chapter_file_id)
    return if chapter_file.file_size.present?

    chapter_file.update_column(:file_size, chapter_file.calculated_file_size)
  rescue ActiveRecord::RecordNotFound
    # Chapter file was deleted, nothing to do
  end
end
