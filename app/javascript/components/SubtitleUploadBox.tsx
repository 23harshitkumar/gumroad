import * as React from "react";

import FileUtils from "$app/utils/file";

import { showAlert } from "$app/components/server-components/Alert";

type UploadBoxProps = {
  onUploadFiles: (domFiles: File[]) => void;
  acceptTypes?: string;
  buttonText?: string;
  validationFn?: (fileName: string) => boolean;
};

const acceptedSubtitleExtensions = FileUtils.getAllowedSubtitleExtensions()
  .map((ext) => `.${ext}`)
  .join(",");

export const SubtitleUploadBox = ({
  onUploadFiles,
  acceptTypes,
  buttonText = "Add subtitles",
  validationFn
}: UploadBoxProps) => {
  const filePickerOnChange = (fileInput: HTMLInputElement) => {
    if (!fileInput.files) return;
    const files = [...fileInput.files];
    const validator = validationFn || ((fileName: string) => FileUtils.isFileNameASubtitle(fileName));
    if (files.some((file) => !validator(file.name))) {
      showAlert("Invalid file type.", "error");
      return;
    }
    fileInput.value = "";
    onUploadFiles(files);
  };

  return (
    <label className="button primary">
      <input
        className="subtitles-file"
        type="file"
        name="file"
        accept={acceptTypes || acceptedSubtitleExtensions}
        tabIndex={-1}
        multiple
        onChange={(e) => filePickerOnChange(e.target)}
      />
      {buttonText}
    </label>
  );
};
