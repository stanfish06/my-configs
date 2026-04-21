# atuin
# run these for the first time
mkdir ~/.local/share/atuin/
atuin init nu | save -f ~/.local/share/atuin/init.nu
source ~/.local/share/atuin/init.nu
# starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
