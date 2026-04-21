# atuin
if not ("~/.local/share/atuin/init.nu" | path expand | path exists) {
    mkdir ~/.local/share/atuin/
    atuin init nu | save -f ~/.local/share/atuin/init.nu
}
source ~/.local/share/atuin/init.nu

# starship
if not (($nu.data-dir | path join "vendor/autoload/starship.nu") | path exists) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
}
