#!/usr/bin/env nu

# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
# It uses ghostty to launch yazi for file selection.
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`.
# Use `journalctl --user -eu xdg-desktop-portal-termfilechooser` for debugging.
def main [
  multiple: string
  directory: string
  save: string
  path: string
  out: string
  loglevel: string
] {
  let base_args = [--chooser-file $out]
  let cwd_file = $"($out).1"

  let args = if ($directory | into bool) {
    $base_args | append [--cwd-file $cwd_file $path]
  } else {
    $base_args | append [$path]
  }

  ghostty -e yazi ...$args

  if ($directory | into bool) {
    # Check if the main output file is missing or empty
    # This happens if the user selected the current directory (cwd) rather than a specific file.
    if not ($out | path exists) or ($out | open | is-empty) {
      # If the 'cwd file' (containing the directory path) exists, we use it as the output.
      if ($cwd_file | path exists) {
        cp $cwd_file $out
        rm $cwd_file
      }
    } else {
      # If the main output file IS valid, we don't need the 'cwd file' anymore.
      # We clean it up to avoid leaving temporary files behind.
      if ($cwd_file | path exists) {
        rm $cwd_file
      }
    }
  }
}
