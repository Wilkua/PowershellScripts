$curPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $curPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function prompt {
    $gitBranch = git symbolic-ref HEAD -q 2>$null
    if (!($null -eq $gitBranch)) {
        $gitBranch = "($($gitBranch -replace 'refs/heads/','')) "
    }
    $curFolder = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curFolder -eq $Env:USERPROFILE) {
        $curFolder = "~"
    } else {
        $curFolder = $curFolder | Split-Path -leaf
    }
    $priv = '$'
    if ($isAdmin) {
        $priv = '#'
    }
    "$Env:USERNAME $gitBranch$($curFolder)$priv "
}
