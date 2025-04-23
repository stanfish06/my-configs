#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
# If (Test-Path "C:\Users\zhiyu\anaconda3\Scripts\conda.exe") {
#     (& "C:\Users\zhiyu\anaconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
# }
#endregion

# posh does not work in wezterm
# Import-Module -Name Terminal-Icons
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/slim.omp.json" | Invoke-Expression
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

#make conda to not set user site path, otherwise pip list will lise global packaegs
$env:PYTHONNOUSERSITE = 1

(& pixi completion --shell powershell) | Out-String | Invoke-Expression

$env:FZF_CTRL_T_OPT = "--preview 'cat {}'"

#add alias for wezterm imgcat
Function imgcat { 
  Param($fname)
  wezterm imgcat $fname
}
#add alias for new-Item
Function touch {
  Param($fname)
  new-Item -Path . -Name $fname -Force -Confirm
}
#alias for btop
Function top {
  cmd.exe /c "set __COMPAT_LAYER=RunAsInvoker && btop4win.exe"
}
#alias for get-Command
Function which {
  Param($prog)
  get-Command $prog
}

#setup zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

#for wezterm shell integration
$prompt = ""
function Invoke-Starship-PreCommand {
    $current_location = $executionContext.SessionState.Path.CurrentLocation
    if ($current_location.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $current_location.ProviderPath -replace "\\", "/"
        $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
    }
    $host.ui.Write($prompt)
}

#for starship
$ENV:STARSHIP_CONFIG = "$HOME\starship.toml"

Invoke-Expression (&starship init powershell)
