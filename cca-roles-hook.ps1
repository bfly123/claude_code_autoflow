#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    param([string]$Start)
    $cur = (Resolve-Path -LiteralPath $Start).ProviderPath
    while ($true) {
        if (Test-Path -LiteralPath (Join-Path $cur '.autoflow') -PathType Container) { return $cur }
        if (Test-Path -LiteralPath (Join-Path $cur '.claude') -PathType Container) { return $cur }
        if (Test-Path -LiteralPath (Join-Path $cur '.git') -PathType Container) { return $cur }
        $parent = Split-Path -Parent $cur
        if (-not $parent -or $parent -eq $cur) { return $cur }
        $cur = $parent
    }
}

function Get-ConfigHome {
    if ($env:XDG_CONFIG_HOME) { return $env:XDG_CONFIG_HOME }
    return (Join-Path $HOME '.config')
}

function Get-MarkerPath {
    param([string]$RepoRoot)
    $today = (Get-Date -Format 'yyyyMMdd')
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($RepoRoot)
    $sha = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    $hex = -join ($sha[0..7] | ForEach-Object { $_.ToString('x2') })
    $name = "cca-roles-hook.$hex.$today.marker"
    $tmp = $env:TEMP
    if (-not $tmp) { $tmp = [System.IO.Path]::GetTempPath() }
    return (Join-Path $tmp $name)
}

function Try-ReadJsonObject {
    param([string]$Path)
    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $obj) { return $null }
        return $obj
    } catch { return $null }
}

function Is-EnabledV1 {
    param($Obj)
    try {
        if ([int]$Obj.schemaVersion -ne 1) { return $false }
        if ($Obj.PSObject.Properties.Name -contains 'enabled') { return [bool]$Obj.enabled }
        return $true
    } catch { return $false }
}

$defaultRoles = @{
    schemaVersion = 1
    enabled       = $true
    executor      = 'codex'
    reviewer      = 'codex'
    documenter    = 'codex'
    designer      = @('claude', 'codex')
    searcher      = 'codex'
    web_searcher  = 'codex'
    repo_searcher = 'codex'
    repo_search_enforced = $false
    git_manager   = 'codex'
}

$repoRoot = Get-RepoRoot -Start (Get-Location).Path
$marker = Get-MarkerPath -RepoRoot $repoRoot
if (Test-Path -LiteralPath $marker) { exit 0 }
try { Set-Content -LiteralPath $marker -Value "ok`n" -Encoding UTF8 -Force } catch { }

$candidates = @(
    @{ Path = (Join-Path $repoRoot '.autoflow\\roles.json'); Label = 'project' }
)

$roles = $null
$source = 'default'
foreach ($c in $candidates) {
    if (-not (Test-Path -LiteralPath $c.Path)) { continue }
    $obj = Try-ReadJsonObject -Path $c.Path
    if (-not $obj) { continue }
    if (-not (Is-EnabledV1 -Obj $obj)) { continue }
    $roles = $obj
    $source = "$($c.Label):$($c.Path)"
    break
}
if (-not $roles) { $roles = $defaultRoles }

Write-Output "[cca roles] source=$source"
Write-Output (($roles | ConvertTo-Json -Depth 16 -Compress))
