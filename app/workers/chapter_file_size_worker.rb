# frozen_string_literal: true

class ChapterFileSizeWorker
  include Sidekiq::Worker

  def perform(chapter_file_id)
    chapter_file = ChapterFile.find(chapter_file_id)
    chapter_file.calculate_size
  rescue ActiveRecord::RecordNotFound
    # ChapterFile was deleted
  end
end
