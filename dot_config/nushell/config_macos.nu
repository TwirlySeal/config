use std/util "path add"

$env.EDITOR = "hx"

# Homebrew
$env.HOMEBREW_PREFIX = "/opt/homebrew";
$env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/opt/homebrew"

path add [
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
]

let env_record = {
  from_string: {|s|
    $s | split row (char esep)
  }

  to_string: { |v|
    $v | str join (char esep)
  }
}

$env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
  "MANPATH": $env_record
  "INFOPATH": $env_record
}

# Empty string is appended so it serialises with a trailing colon, needed to
# still include the default system paths.
$env.MANPATH = ($env.MANPATH? | default [] | append "/opt/homebrew/share/man" "")
$env.INFOPATH = ($env.INFOPATH? | default [] | append "/opt/homebrew/share/info" "")

path add [
  "~/go/bin"
  "~/.cargo/bin" # Rust
  "~/.local/bin" # uv

  # Haskell
  "~/.ghcup/bin"
  "~/.cabal/bin"

  # "~/.pub-cache/bin" # Dart
  # "~/.dotnet/tools"
]

# OCaml
const opam_cache = $nu.cache-dir | path join "opam.nuon"

if not ($opam_cache | path exists) {
  opam env --shell=powershell
  | lines
  | parse "$env:{key} = '{val}'"
  | transpose -rd
  | to nuon
  | save --force $opam_cache
}

open $opam_cache | load-env

# $env.DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec"
# $env.JAVA_HOME = (/usr/libexec/java_home)
