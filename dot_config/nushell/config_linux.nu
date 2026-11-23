use std/util "path add"

$env.EDITOR = "helix"
$env.config.buffer_editor = "helix"

$env.UV_PYTHON_DOWNLOADS = 'manual'

path add [
  "/home/ethan/.cargo/bin"
  "/home/ethan/go/bin"
  "/home/ethan/.local/bin" # uv
]

# Commands
def pg-start [] {
  sudo mkdir -p /run/postgresql/
  sudo chown postgres:postgres /run/postgresql/
  sudo -u postgres postgres -D /var/lib/postgres/data
}

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
