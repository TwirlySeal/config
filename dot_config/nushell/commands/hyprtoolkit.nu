const hypr_config = "~/.config/hypr" | path expand
const themes = $hypr_config | path join "catppuccin-hyprtoolkit/themes/"

def complete-themes [] {
  glob ($themes | path join **/*.conf)
  | path relative-to $themes
  | str replace '.conf' ''
}

# Select a hyprtoolkit catppuccin theme.
export def hyprtoolkit-theme [
  theme: string@complete-themes
] {
  let full_path = ($themes | path join $theme) + ".conf"

  if not ($full_path | path exists) {
    let span = (metadata $theme).span
    error make {
      msg: "Invalid theme",
      label: {
        text: "here",
        span: $span
      }
    }
  }

  ln -sf $full_path ($hypr_config | path join "hyprtoolkit.conf")
}
