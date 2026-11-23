def flags [...flags: string] {
  $flags | prepend '-' | str join
}

def map-flags [map: record] {
  $map
  | transpose flag enabled
  | where enabled
  | get flag
}

# pacman wrapper
def pac [] {
  help pac
}

def "pac install" [...packages: string] {
  paru -S ...$packages
}

# todo: add flag to remove nosave option
def "pac uninstall" [...packages: string] {
  paru -Rsn ...$packages
}

def "pac list" [--installed-on-request] {
  let flags = map-flags {
    e: $installed_on_request
  }

  paru (flags 'Q' ...$flags)
}

def "pac upgrade" [] {
  paru -Syu
}

def "pac search" [
  query: string
  --local (-l)
] {
  let source = if $local {
    'Q'
  } else {
    'S'
  }

  paru (flags $source 's') $query
}

# Display information on a given package
def "pac info" [
  package: string
  --remote (-r)
] {
  let source = if $remote {
    'S'
  } else {
    'Q'
  }

  paru (flags $source 'i') $package
}

def "pac set-reason" [
  package: string
  --dep
] {
  let reason = if $dep {
    "--asdeps"
  } else {
    "--asexplicit"
  }

  pacman -D $reason $package
}

# Uninstall packages that were only installed as a dependency of another package and are now no longer needed.
def "pac autoremove" [
  --dry-run # List what would be uninstalled, but do not actually uninstall anything.
] {
  let removals = paru -Qdtq

  if $dry_run {
    print $removals
  } else {
    paru -Rsn $removals
  }
}
