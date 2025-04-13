#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\zhiyu\anaconda3\Scripts\conda.exe") {
    (& "C:\Users\zhiyu\anaconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

Import-Module -Name Terminal-Icons
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/slim.omp.json" | Invoke-Expression
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

#setup zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
