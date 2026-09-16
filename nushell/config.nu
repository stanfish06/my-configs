const nushell_config_folder = path self .
const dummy_file = ($nushell_config_folder | path join "dummy.nu") 

# generated init scripts: nushell needs `source` targets to exist at parse time, so the
# first launch after a tool appears sources dummy.nu and the real script takes effect next launch
const atuin_init = ("~/.local/share/atuin/init.nu" | path expand)
if (which atuin | is-not-empty) and not ($atuin_init | path exists) {
    mkdir ($atuin_init | path dirname)
    atuin init nu | save -f $atuin_init
}
const atuin_src = (if ($atuin_init | path exists) { $atuin_init } else { $dummy_file })
source $atuin_src

const mise_init = ("~/.local/share/mise/init.nu" | path expand)
if (which mise | is-not-empty) and not ($mise_init | path exists) {
    mkdir ($mise_init | path dirname)
    mise activate nu | save -f $mise_init
}
const mise_src = (if ($mise_init | path exists) { $mise_init } else { $dummy_file })
source $mise_src

const zoxide_init = ("~/.local/share/zoxide/init.nu" | path expand)
if (which zoxide | is-not-empty) and not ($zoxide_init | path exists) {
    mkdir ($zoxide_init | path dirname)
    zoxide init nushell | save -f $zoxide_init
}
const zoxide_src = (if ($zoxide_init | path exists) { $zoxide_init } else { $dummy_file })
source $zoxide_src

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
alias ll = ls -l
alias eza = ^eza --icons auto
alias le = eza --group-directories-first
alias led = eza --group-directories-last
alias larth = eza -lah -snew --git --group-directories-first
alias lt = eza --tree --level=2 --group-directories-first
alias lta = eza --tree --level=2 -a --group-directories-first
