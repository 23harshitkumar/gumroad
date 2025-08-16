// Shared type definitions for file-related components

export type ChapterFile = {
  file_name: string;
  extension: string;
  language: string;
  file_size: null | number;
  url: string;
  signed_url: string;
  status:
    | { type: "saved" }
    | { type: "existing" }
    | { type: "unsaved"; uploadStatus: { type: "uploaded" } | { type: "uploading"; progress: UploadProgress } };
};

// Re-export for consistency with existing usage
export type SubtitleFile = {
  file_name: string;
  extension: string;
  language: string;
  file_size: null | number;
  url: string;
  signed_url: string;
  status:
    | { type: "saved" }
    | { type: "existing" }
    | { type: "unsaved"; uploadStatus: { type: "uploaded" } | { type: "uploading"; progress: UploadProgress } };
};

// File state types for upload management
export type ChapterFileState = ChapterFile & { status: FileStatus };
export type SubtitleFileState = SubtitleFile & { status: FileStatus };

// Import UploadProgress type
import { UploadProgress } from "$app/components/useConfigureEvaporate";

// FileStatus type used in upload states
type FileStatus =
  | {
      type: "saved";
    }
  | {
      type: "existing";
    }
  | {
      type: "unsaved";
      uploadStatus: { type: "uploaded" } | { type: "uploading"; progress: UploadProgress };
    };
