#!/usr/bin/env nu

def main [
  destination: path # File in home directory
  source: path # File in chezmoi source directory
  target: path # Target file state rendered by chezmoi
] {
  # Empty file as common ancestor
  let base = "/dev/null"

  # Write conflict markers into $destination
  try {
    git merge-file -L "SOURCE" -L "BASE" -L "DESTINATION" $source $base $destination
  }

  if $nu.os-info.name == "linux" {
    helix $source
  } else {
    hx $source
  }
}
