let os_name = $nu.os-info.name

if $os_name == "linux" {
  # Carapace
  $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
  mkdir $nu.cache-dir
  carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

  $env.EDITOR = "helix"
}

if $os_name == "macos" {
  # Homebrew
  $env.HOMEBREW_PREFIX = "/opt/homebrew";
  $env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
  $env.HOMEBREW_REPOSITORY = "/opt/homebrew"

  $env.PATH ++= [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ]

  let env_record = {
    from_string: {|s|
      $s
      | split row (char esep)
      | path expand --no-symlink
    }

    to_string: { |v|
      $v
      | path expand --no-symlink
      | str join (char esep)
    }
  }

  $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
    "MANPATH": $env_record
    "INFOPATH": $env_record
  }

  $env.MANPATH = ($env.MANPATH? | default [] | append "/opt/homebrew/share/man")
  $env.INFOPATH = ($env.INFOPATH? | default [] | append "/opt/homebrew/share/info")

  # Carapace
  $env.CARAPACE_BRIDGES = 'zsh'
  mkdir $"($nu.cache-dir)"
  carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
  source $"($nu.cache-dir)/carapace.nu"

  $env.PATH ++= [
    "/opt/homebrew/bin"
    "~/go/bin"
    "~/.cargo/bin"
    "~/.local/bin" # uv
    "~/.pub-cache/bin" # Dart

    # Haskell
    "~/.ghcup/bin"
    "~/.cabal/bin"

    # "~/.dotnet/tools"
  ]

  opam env --shell=powershell
    | lines
    | parse "$env:{key} = '{val}'"
    | transpose -rd
    | load-env

  $env.EDITOR = "hx"

  # $env.DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec"
  # $env.JAVA_HOME = (/usr/libexec/java_home)
}
