# frozen_string_literal: true

require "spec_helper"

describe ChapterFile do
  describe "validations" do
    describe "file types" do
      shared_examples "common invalid type behavior" do |file_type:|
        before do
          @chapter = build(:chapter_file, url: "chapter.#{file_type}")
        end

        it "is invalid" do
          expect(@chapter).not_to be_valid
        end

        it "does not save the record" do
          expect do
            @chapter.save
          end.not_to change { ChapterFile.count }
        end

        it "displays an unsupported file type error message" do
          @chapter.save
          expect(@chapter.errors.full_messages[0]).to include("Chapter file type not supported.")
        end
      end

      shared_examples "common valid type behavior" do |file_type:|
        before do
          @chapter = build(:chapter_file, url: "chapter.#{file_type}")
        end

        it "is valid" do
          expect(@chapter).to be_valid
        end

        it "saves the record" do
          expect do
            @chapter.save
          end.to change { ChapterFile.count }.by(1)
        end
      end

      context "when uploading an invalid type" do
        include_examples "common invalid type behavior", file_type: "txt"
        include_examples "common invalid type behavior", file_type: "mov"
        include_examples "common invalid type behavior", file_type: "mp4"
        include_examples "common invalid type behavior", file_type: "mp3"
        include_examples "common invalid type behavior", file_type: "srt"

        context "and chapter is an S3 URL" do
          before do
            @chapter = build(:chapter_file, url: "https://s3.amazonaws.com/gumroad/attachments/1234/abcdef/original/My Awesome Youtube video.mov")
          end

          it "is invalid" do
            expect(@chapter).not_to be_valid
          end
        end
      end

      context "when uploading a valid type" do
        include_examples "common valid type behavior", file_type: "vtt"

        context "and chapter is an S3 URL" do
          before do
            @chapter = build(:chapter_file, url: "https://s3.amazonaws.com/gumroad/attachments/1234/abcdef/original/My Chapters.vtt")
          end

          it "is valid" do
            expect(@chapter).to be_valid
          end
        end
      end
    end
  end

  describe "#has_alive_duplicate_files?" do
    let!(:file_1) { create(:chapter_file, url: "https://s3.amazonaws.com/gumroad-specs/some-file.vtt") }
    let!(:file_2) { create(:chapter_file, url: "https://s3.amazonaws.com/gumroad-specs/some-file.vtt") }

    it "returns true if there's an alive record with the same url" do
      file_1.mark_deleted
      file_1.save!
      expect(file_1.has_alive_duplicate_files?).to eq(true)
      expect(file_2.has_alive_duplicate_files?).to eq(true)
    end

    it "returns false if there's no other alive record with the same url" do
      file_1.mark_deleted
      file_1.save!
      file_2.mark_deleted
      file_2.save!
      expect(file_1.has_alive_duplicate_files?).to eq(false)
      expect(file_2.has_alive_duplicate_files?).to eq(false)
    end
  end
end
