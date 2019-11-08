$curPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $curPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function prompt {
    # Determine the Git branch information
    $gitInfo = ''
    $gitHasStaged = $false
    $gitHasUnstaged = $false
    $gitUntracked = ''
    $gitStatus = git status --porcelain --branch
    if ($gitStatus -ne $null) {
        $gitStatus = $gitStatus -split "`r`n"
        $gitBranch = $null
        foreach ($line in $gitStatus) {
            if ($line.StartsWith('## ')) {
                $gitBranch = ($line -replace '## ','') -replace '\.\.\..*',''
            } elseif ($line.StartsWith(' M ')) {
                $gitHasUnstaged = $true
            } elseif ($line.StartsWith('M  ') -or $line.StartsWith('A  ')) {
                $gitHasStaged = $true
            } elseif ($line.StartsWith('?? ')) {
                $gitUntracked = '? '
            }
        }

        $foregroundColor = 'White'
        if ($gitHasStaged -eq $true) {
            if ($gitHasUnstaged -eq $true) {
                $foregroundColor = 'Blue'
            } else {
                $foregroundColor = 'Green'
            }
        } elseif ($gitHasUnstaged -eq $true) {
            $foregroundColor = 'Red'
        }

        if ($gitBranch -ne $null) {
            $gitInfo = "($gitUntracked$gitBranch) "
        }

        Write-Host -NoNewline -ForegroundColor $foregroundColor $gitInfo
    }

    # Build the dir prompt
    $curFolder = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curFolder -eq $Env:USERPROFILE) {
        $curFolder = "~"
    } else {
        $curFolder = $curFolder | Split-Path -leaf
    }
    Write-Host -NoNewline $curFolder

    # Build the prompt glyph
    $priv = '$'
    if ($isAdmin) {
        $priv = '#'
    }
    Write-Host -NoNewline $priv

    return " "
}
