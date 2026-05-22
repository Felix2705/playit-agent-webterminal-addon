param(
    [string]$RepoUrl = "https://github.com/Felix2705/playit-agent-webterminal-addon",
    [string]$Branch = "main",
    [string]$ExcludeDir = "dev",
    [switch]$NoWait,

    [string]$GitHubToken = "",
    [switch]$InteractiveAuth
)

$GitHubTokenInline = ""

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($GitHubToken) -and -not [string]::IsNullOrWhiteSpace($GitHubTokenInline)) {
    $GitHubToken = $GitHubTokenInline
}

function Get-TokenFromUser {
    $sec = Read-Host -Prompt "GitHub Personal Access Token (PAT) eingeben (Secure) " -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
    try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) } finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

$sourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = (Resolve-Path -LiteralPath $MyInvocation.MyCommand.Path).Path
$workDir = Join-Path $env:TEMP ("playit-agent-webterminal-addon_publish_" + [Guid]::NewGuid().ToString())

$ExcludeDirs = @($ExcludeDir, ".sixth", "__pycache__")
$ExcludeFilesExact = @("playit-agent-webterminal-addon.code-workspace")

function Remove-IfExists($path) {
    if (Test-Path $path) { Remove-Item -Recurse -Force $path }
}

function Ensure-Dir($path) {
    if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function ShouldSkipItem {
    param([Parameter(Mandatory=$true)] $item)

    if ($item.Name -eq ".git") { return $true }
    if ($item.PSIsContainer -and ($ExcludeDirs -contains $item.Name)) { return $true }
    if ($item.PSIsContainer -and $item.Name -eq "_publish_tmp_clone") { return $true }
    if (!$item.PSIsContainer -and ($ExcludeFilesExact -contains $item.Name)) { return $true }
    if (!$item.PSIsContainer -and $item.Extension -eq ".pyc") { return $true }
    if (!$item.PSIsContainer -and $item.FullName -eq $scriptPath) { return $true }
    return $false
}

function Copy-Filtered {
    param([string]$src,[string]$dst)

    Ensure-Dir $dst
    $items = Get-ChildItem -Force -LiteralPath $src
    foreach ($item in $items) {
        if (ShouldSkipItem -item $item) { continue }
        $targetPath = Join-Path $dst $item.Name
        if ($item.PSIsContainer) {
            Copy-Filtered -src $item.FullName -dst $targetPath
        } else {
            Copy-Item -Force -LiteralPath $item.FullName -Destination $targetPath
        }
    }
}

function Wait-ForUser { Read-Host -Prompt "Script beendet. ENTER drücken zum Schließen..." }

function Resolve-PushUrl {
    param([string]$Url,[string]$Token,[switch]$UseToken)

    if (-not $UseToken) { return $Url }
    $tokenEsc = [Uri]::EscapeDataString($Token)
    if ($Url.StartsWith("https://", [System.StringComparison]::OrdinalIgnoreCase)) {
        $withoutScheme = $Url.Substring("https://".Length)
        return "https://x-access-token:$tokenEsc@$withoutScheme"
    }
    return $Url
}

$exitCode = 0
try {
    Remove-IfExists $workDir

    if ($InteractiveAuth.IsPresent) {
        if ($NoWait.IsPresent) { throw "InteractiveAuth kann in NoWait/Tool-Runs hängen." }
        $pushUrl = $RepoUrl
    } else {
        if (-not [string]::IsNullOrWhiteSpace($GitHubToken)) {
            $pushUrl = Resolve-PushUrl -Url $RepoUrl -Token $GitHubToken -UseToken
        } elseif ($NoWait.IsPresent) {
            $pushUrl = $RepoUrl
        } else {
            $GitHubToken = Get-TokenFromUser
            $pushUrl = Resolve-PushUrl -Url $RepoUrl -Token $GitHubToken -UseToken
        }
    }

    git clone --depth 1 --branch $Branch $RepoUrl $workDir
    $cloneRoot = $workDir

    $cloneItems = Get-ChildItem -Force -LiteralPath $cloneRoot
    foreach ($ci in $cloneItems) {
        if ($ci.Name -eq ".git") { continue }
        Remove-Item -Recurse -Force -LiteralPath $ci.FullName
    }

    Copy-Filtered -src $sourceRoot -dst $cloneRoot

    Set-Location $cloneRoot
    git add -A
    git config user.name "publish-bot"
    git config user.email "publish-bot@local"
    $commitMsg = "Publish: Playit Agent WebTerminal ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    git commit -m $commitMsg --allow-empty
    if ($pushUrl -ne $RepoUrl) { git remote set-url origin $pushUrl }
    git push origin $Branch
}
catch {
    $exitCode = 1
    Write-Host "ERROR: $($_.Exception.Message)"
    Write-Host "Details:"
    Write-Host $_
}
finally {
    if (-not $NoWait) { Wait-ForUser }
    exit $exitCode
}
