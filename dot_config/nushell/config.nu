$env.config.show_banner = false

const $os_name = $nu.os-info.name

# OS-specific config
const os_config = $"config_($nu.os-info.name).nu"
source $os_config


# Carapace
const carapace_cache = $nu.cache-dir | path join "carapace.nu"

if not ($carapace_cache | path exists) {
  mkdir $"($nu.cache-dir)"
  carapace _carapace nushell | save --force $carapace_cache
}
$env.CARAPACE_BRIDGES = 'zsh,bash'
source $carapace_cache


# Commands
def scrub-username []: string -> string {
  $in | str replace --all $env.USER "username"
}

def scrub-home []: string -> string {
  $in | str replace --all $nu.home-dir "~"
}

def scrub-work-dir []: string -> string {
  $in | str replace --all $env.PWD "."
}

def scrub-paths []: string -> string {
  $in | scrub-work-dir | scrub-home
}

def pdoc [
  file: path
  ...args
] {
  const themes = $nu.default-config-dir | path join "themes"
  const css_theme = $themes | path join "theme.css"
  const syntax_theme = $themes | path join "mocha.theme"

  let output = $file
  | path parse
  | reject parent
  | upsert extension { 'html' }
  | path join

  (
    pandoc $file --standalone --output $output
    --css $css_theme
    --syntax-highlighting $syntax_theme
    --mathml --embed-resources ...$args
  )
}

def cabal-init [] {
  cabal init --verbose=0
  rm CHANGELOG.md
}

def with-cleanup [
    startup: closure,
    teardown: closure
] {
    do $startup

    # Block until interrupted
    try {
        print "Running. Press Ctrl+C to stop..."
        loop {
            sleep 1sec
        }
    } catch { |err|
        # Intercept Ctrl+C or failure
        print "\nInterrupted. Running teardown..."
        do $teardown
    }
}
