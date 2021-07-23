function Test-NvimManagerRequirements
{
	[CmdletBinding()]
	param(
		[switch] $Report
	)

	$success = ' ' # true
	if ($Report)
	{
		Write-Host ''
		Write-Host 'Neovim Manager Module Requirements'
		Write-Host '----------------------------------'
	}

	$gitInstalled = Get-Command -ErrorAction SilentlyContinue "git"
	if (-Not $gitInstalled)
	{
		$success = '' # fasle
		if ($Report)
		{
			Write-Host -NoNewline 'Git ................ '
			Write-Host -ForegroundColor Red 'Not Installed'
		}
	}
	else
	{
		if ($Report)
		{
			Write-Host -NoNewline 'Git .................... '
			Write-Host -ForegroundCOlor Green 'Installed'
		}
	}

	return $success
}

function _ensurePluginPath
{
	param(
		[Parameter(Mandatory, Position=0)]
		[string] $Path
	)

	if (-Not (Test-Path -Path $Path))
	{
		$_ = New-Item -ItemType 'Directory' -Path $nvimPluginPath
	}

	if (-Not (Test-Path -Path $Path))
	{
		return '' # false
	}

	return ' ' # true
}

function Get-NvimPluginPath
{
	# Note: This should probalby invoke nvim and have it echo stdpath('data')
	[CmdletBinding()]
	param (
		[switch] $EnsurePath
	)

	$userLocalAppData = "$Env:USERPROFILE\AppData\Local"
	$nvimPluginPath = "$userLocalAppData\nvim-data\site\pack\0\start"

	if ($EnsurePath)
	{
		if (-Not (_ensurePluginPath $nvimPluginPath))
		{
			return ''
		}
	}

	return $nvimPluginPath
}

function Install-NvimPlugin
{
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline, Position=0)]
		[string] $GithubRepo,
		[string] $GitUrl
	)

	process
	{
		if (-Not (Test-NvimManagerRequirements))
		{
			Write-Error -Message 'Neovim Manager requirements are not met - Run Check-NvimManagerRequirements -Report for more information'
			return '' # false
		}

		$nvimPluginPath = Get-NvimPluginPath -EnsurePath
		if (-Not $nvimPluginPath)
		{
			Write-Error -Message "Failed to create plugin install path $nvimPluginPath"
			return '' # false
		}

		if ($GithubRepo)
		{
			Write-Host "Cloning from GitHub repository $GithubRepo ..."
			git -C "$nvimPluginPath" clone -q --recurse-submodules "https://github.com/$GithubRepo"
			Write-Host "Done cloning plugin"
		}
	}
}

function Get-NvimInstalledPlugins
{
	[CmdletBinding()]
	param (
		[switch] $WithPaths
	)

	$nvimPluginPath = Get-NvimPluginPath -EnsurePath
	$plugins = Get-ChildItem -Path $nvimPluginPath

	if ($WithPaths)
	{
		return $plugins
	}

	$noPathPlugins = @()
	foreach ($plugin in $plugins)
	{
		$noPathPlugins += (Split-Path -Path $plugin -Leaf)
	}

	return $noPathPlugins
}

Export-ModuleMember -Function 'Get-NvimInstalledPlugins', 'Install-NvimPlugin', 'Get-NvimPluginPath', 'Test-NvimManagerRequirements'

