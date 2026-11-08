$env.config.show_banner = false

def scrub-home []: string -> string {
  $in | str replace --all $nu.home-dir "~"
}

def scrub-work-dir []: string -> string {
  $in | str replace --all $env.PWD "."
}

def scrub-all []: string -> string {
  $in | scrub-work-dir | scrub-home
}

def pdoc [
  file: path
  ...args
] {
  let themes = $nu.default-config-dir | path join "themes"
  let css_theme = $themes | path join "theme.css"
  let syntax_theme = $themes | path join "mocha.theme"

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
