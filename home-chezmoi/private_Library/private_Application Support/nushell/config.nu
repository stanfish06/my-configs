const nushell_config_folder = path self .
const dummy_file = ($nushell_config_folder | path join "dummy.nu") 

# atuin
const init_file = ("~/.local/share/atuin/init.nu" | path expand) 
if (which atuin | is-not-empty) {
    if not ($init_file | path exists) {
        mkdir ~/.local/share/atuin/
        atuin init nu | save -f $init_file
    } 
} 
const atuin_init = (if ($init_file | path exists) { $init_file } else { $dummy_file })
source $atuin_init

# starship
if (which starship | is-not-empty) {
    if not (($nu.data-dir | path join "vendor/autoload/starship.nu") | path exists) {
        mkdir ($nu.data-dir | path join "vendor/autoload")
        starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
    }
}

# start at home
cd ~

# alias
alias l = ls
