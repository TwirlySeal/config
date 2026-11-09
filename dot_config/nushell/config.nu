$env.config.show_banner = false

let $os_name = $nu.os-info.name

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

if $os_name == "linux" {
  source $"($nu.cache-dir)/carapace.nu"

  $env.UV_PYTHON_DOWNLOADS = 'manual'

  $env.config.buffer_editor = "helix"
  alias hx = helix

  def pg-start [] {
    sudo mkdir -p /run/postgresql/
    sudo chown postgres:postgres /run/postgresql/
    sudo -u postgres postgres -D /var/lib/postgres/data
  }

  $env.path ++= [
    "/home/ethan/.cargo/bin"
    "/home/ethan/go/bin"
    "/home/ethan/.local/bin" # uv
  ]

  def time [] {
    date now | format date "%I:%M"
  }

  # yazi wrapper
  def --env y [...args] {
  	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  	yazi ...$args --cwd-file $tmp
  	let cwd = (open $tmp)
  	if $cwd != "" and $cwd != $env.PWD {
  		cd $cwd
  	}
  	rm -fp $tmp
  }

  source commands/pac.nu
  use commands/hyprtoolkit.nu *

  # 7zip wrapper
  def archive [] {
    help archive
  }

  def "archive extract" [
    path: path
    --delete (-d)
  ] {
    let stem = $path | path parse | get stem
    7z x $path -o($stem)

    if $delete {
      rm $path
    }
  }
}
