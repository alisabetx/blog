# ================================
# Auto Git Commit & Push Script (robust logging + correct quoting)
# Repo: D:\Obsidian
# Logs: D:\Obsidian\.logs\auto-git-push_YYYY-MM-DD.log
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoPath = "D:\Obsidian"
$LogDir   = Join-Path $RepoPath ".logs"
$LogFile  = Join-Path $LogDir ("auto-git-push_{0}.log" -f (Get-Date -Format "yyyy-MM-dd"))

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[{0}] [{1}] {2}" -f $ts, $Level, $Message
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Quote-Arg([string]$a) {
    if ($null -eq $a) { return '""' }
    # Quote if contains whitespace or quotes or special chars
    if ($a -match '[\s"`^&|<>]') {
        # Escape embedded double quotes for Windows command-line
        $escaped = $a -replace '"', '\"'
        return '"' + $escaped + '"'
    }
    return $a
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)][string[]]$Args
    )

    $outFile = [System.IO.Path]::GetTempFileName()
    $errFile = [System.IO.Path]::GetTempFileName()

    # Build a single argument string with proper quoting
    $argString = ($Args | ForEach-Object { Quote-Arg $_ }) -join ' '

    try {
        $p = Start-Process -FilePath "git" `
            -ArgumentList $argString `
            -WorkingDirectory $RepoPath `
            -NoNewWindow `
            -Wait `
            -PassThru `
            -RedirectStandardOutput $outFile `
            -RedirectStandardError  $errFile

        $stdout = ""
        $stderr = ""
        if (Test-Path $outFile) { $stdout = (Get-Content -LiteralPath $outFile -Raw -ErrorAction SilentlyContinue) }
        if (Test-Path $errFile) { $stderr = (Get-Content -LiteralPath $errFile -Raw -ErrorAction SilentlyContinue) }

        return [pscustomobject]@{
            ExitCode = $p.ExitCode
            StdOut   = $stdout
            StdErr   = $stderr
            Command  = ("git " + $argString)
        }
    }
    finally {
        Remove-Item -LiteralPath $outFile -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue
    }
}

try {
    if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
        throw "Repository path not found: $RepoPath"
    }

    Ensure-Dir $LogDir

    Write-Log "========== Auto Git Push START =========="

    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCmd) {
        throw "git is not available in PATH"
    }
    Write-Log "Git detected: $($gitCmd.Source)"

    # Ensure repo
    $r = Invoke-Git @("rev-parse","--is-inside-work-tree")
    if ($r.ExitCode -ne 0 -or $r.StdOut.Trim() -ne "true") {
        Write-Log $r.Command "ERROR"
        if ($r.StdErr) { Write-Log ($r.StdErr.Trim()) "ERROR" }
        throw "This directory is not a git repository"
    }

    # Current branch
    $b = Invoke-Git @("branch","--show-current")
    if ($b.ExitCode -ne 0) {
        Write-Log $b.Command "ERROR"
        if ($b.StdErr) { Write-Log ($b.StdErr.Trim()) "ERROR" }
        throw "Cannot detect current branch"
    }
    $branch = $b.StdOut.Trim()
    Write-Log "Current branch: $branch"

    # Remote exists?
    $rem = Invoke-Git @("remote")
    if ($rem.ExitCode -ne 0) {
        Write-Log $rem.Command "ERROR"
        if ($rem.StdErr) { Write-Log ($rem.StdErr.Trim()) "ERROR" }
        throw "Cannot read git remotes"
    }
    if ([string]::IsNullOrWhiteSpace($rem.StdOut)) {
        throw "No git remote configured"
    }
    Write-Log ("Remote(s): " + ($rem.StdOut.Trim() -replace "\r?\n", ", "))

    # Refresh index
    [void](Invoke-Git @("update-index","-q","--refresh"))

    # Check changes
    $st = Invoke-Git @("status","--porcelain")
    if ($st.ExitCode -ne 0) {
        Write-Log $st.Command "ERROR"
        if ($st.StdErr) { Write-Log ($st.StdErr.Trim()) "ERROR" }
        throw "git status failed"
    }

    if ([string]::IsNullOrWhiteSpace($st.StdOut)) {
        Write-Log "No changes detected. Nothing to commit."
        Write-Log "========== Auto Git Push END =========="
        exit 0
    }

    Write-Log "Changes detected:"
    $st.StdOut -split "`r?`n" | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_)) { Write-Log ("  " + $_.Trim()) }
    }

    # Stage
    $add = Invoke-Git @("add","-A")
    if ($add.ExitCode -ne 0) {
        Write-Log $add.Command "ERROR"
        if ($add.StdOut) { Write-Log ($add.StdOut.Trim()) "ERROR" }
        if ($add.StdErr) { Write-Log ($add.StdErr.Trim()) "ERROR" }
        throw "git add failed"
    }
    Write-Log "All changes staged"

    # Commit (IMPORTANT: use --message= to avoid spacing issues)
    $commitMsg = "Auto update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $cm = Invoke-Git @("commit","--message=$commitMsg")
    if ($cm.ExitCode -ne 0) {
        Write-Log $cm.Command "ERROR"
        if ($cm.StdOut) { Write-Log ($cm.StdOut.Trim()) "ERROR" }
        if ($cm.StdErr) { Write-Log ($cm.StdErr.Trim()) "ERROR" }
        throw "git commit failed"
    }
    if ($cm.StdOut) { Write-Log ($cm.StdOut.Trim()) }
    if ($cm.StdErr) { Write-Log ($cm.StdErr.Trim()) "WARN" }
    Write-Log "Committed with message: $commitMsg"

    # Push
    Write-Log "Pushing to remote..."
    $ps = Invoke-Git @("push")
    Write-Log $ps.Command
    if ($ps.StdOut) { ($ps.StdOut -split "`r?`n") | ForEach-Object { if($_){ Write-Log $_ } } }
    if ($ps.StdErr) { ($ps.StdErr -split "`r?`n") | ForEach-Object { if($_){ Write-Log $_ "WARN" } } }

    if ($ps.ExitCode -ne 0) {
        throw "git push failed (ExitCode=$($ps.ExitCode))"
    }

    Write-Log "Push successful"
    Write-Log "========== Auto Git Push END =========="
    exit 0
}
catch {
    Write-Log ("FATAL ERROR: " + $_.Exception.Message) "ERROR"
    Write-Log (($_ | Out-String).Trim()) "ERROR"
    Write-Log "========== Auto Git Push FAILED =========="
    exit 1
}
