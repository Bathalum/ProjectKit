# ProjectKit bootstrap -- instantiate or refresh the kit in a project directory.
#
# One command, from the project root (no clone of ProjectKit needed):
#   irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex
#
# Or from a local kit / a repo created from the template:
#   powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1 [target-dir]
#
# Idempotent. Kit-owned skills are refreshed; AGENTS.md, the wiki and CLAUDE.md
# are created only when missing -- never overwritten.

$ErrorActionPreference = 'Stop'
$RepoUrl = 'https://github.com/Bathalum/ProjectKit.git'
$OneLiner = 'irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex'
$OneLinerSh = 'curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash'

function Copy-Tree([string]$From, [string]$To, [bool]$Overwrite) {
    $From = (Resolve-Path -LiteralPath $From).Path
    Get-ChildItem -LiteralPath $From -Recurse -File -Force | ForEach-Object {
        $rel = $_.FullName.Substring($From.Length).TrimStart('\', '/')
        $dest = Join-Path $To $rel
        if ($Overwrite -or -not (Test-Path -LiteralPath $dest)) {
            $dir = Split-Path -Parent $dest
            if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
    }
}

function Get-WikiRoot([string]$Root) {
    $f = Join-Path $Root '.cursor\wiki-root'
    if (Test-Path -LiteralPath $f) {
        foreach ($line in Get-Content -LiteralPath $f) {
            $t = $line.Trim()
            if ($t -and -not $t.StartsWith('#')) { return $t.TrimEnd('/', '\') }
        }
    }
    return 'docs'
}

function Write-Utf8([string]$Path, [string]$Text) {
    [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding $false))
}

$Target = if ($args.Count -gt 0) { (Resolve-Path -LiteralPath $args[0]).Path } else { (Get-Location).Path }

# Kit source: the kit this script lives in, else a fresh shallow clone.
$Src = $null
$Tmp = $null
if ($PSScriptRoot) {
    $here = Split-Path -Parent $PSScriptRoot
    if (Test-Path -LiteralPath (Join-Path $here 'Constitution\AGENTS.md')) { $Src = $here }
}

try {
    if (-not $Src) {
        $Tmp = Join-Path ([IO.Path]::GetTempPath()) ('projectkit-' + [guid]::NewGuid())
        git clone -q --depth 1 $RepoUrl (Join-Path $Tmp 'ProjectKit')
        if ($LASTEXITCODE -ne 0) { throw 'git clone of ProjectKit failed' }
        $Src = Join-Path $Tmp 'ProjectKit'
    }
    $sameDir = ((Resolve-Path -LiteralPath $Src).Path -eq $Target)

    Write-Host "ProjectKit -> $Target"

    # 1. Skills: kit owns them -- refresh (extra project-local skills are kept).
    if (-not $sameDir) {
        Copy-Tree (Join-Path $Src '.cursor\skills') (Join-Path $Target '.cursor\skills') $true
        Copy-Tree (Join-Path $Src '.cursor') (Join-Path $Target '.cursor') $false   # wiki-root if missing
        Write-Host '  skills      refreshed (.cursor/skills)'
    }

    # 2. Law + wiki: project owns them -- add only what is missing.
    $wikiRoot = Get-WikiRoot $Target
    $wikiParent = Split-Path -Parent $wikiRoot
    $agentsRel = if ($wikiParent) { "$wikiParent/AGENTS.md" } else { 'AGENTS.md' }
    $agentsPath = Join-Path $Target $agentsRel
    if (-not (Test-Path -LiteralPath $agentsPath)) {
        Copy-Item -LiteralPath (Join-Path $Src 'Constitution\AGENTS.md') -Destination $agentsPath
        Write-Host "  law         created ($agentsRel)"
    }
    Copy-Tree (Join-Path $Src 'Constitution\docs') (Join-Path $Target $wikiRoot) $false
    Write-Host "  wiki        missing stubs added ($wikiRoot/)"

    # 3. Claude Code bridge: CLAUDE.md thin pointer (AGENTS.md "Tool bridge").
    $claudeMd = Join-Path $Target 'CLAUDE.md'
    if (-not (Test-Path -LiteralPath $claudeMd)) {
        $text = @"
# CLAUDE.md

Thin pointer -- the law lives in [``$agentsRel``](./$agentsRel) (SSOT). Do not fork rules here.

@$agentsRel

## Skills

Kit skills live in ``.cursor/skills/`` (SSOT). ``.claude/skills`` is a local link to it and is git-ignored.
If ``.claude/skills`` is missing (fresh clone), run from the repo root:

- PowerShell: ``$OneLiner``
- bash: ``$OneLinerSh``

"@
        Write-Utf8 $claudeMd $text
        Write-Host '  claude      created (CLAUDE.md -> AGENTS.md)'
    }

    # 4. Claude Code bridge: .claude/skills -> .cursor/skills (link, not a copy).
    $linkDir = Join-Path $Target '.claude'
    $link = Join-Path $linkDir 'skills'
    $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType) {
        Write-Host '  link        ok (.claude/skills)'
    } elseif ($existing) {
        Write-Warning '.claude/skills is a real folder -- left alone. Move its skills into .cursor/skills and re-run.'
    } else {
        if (-not (Test-Path -LiteralPath $linkDir)) { New-Item -ItemType Directory -Path $linkDir | Out-Null }
        $onWindows = ($PSVersionTable.PSEdition -ne 'Core') -or $IsWindows
        if ($onWindows) {
            # Relative symlink needs Developer Mode/admin; junction works for everyone.
            cmd /c "mklink /D `"$link`" `"..\.cursor\skills`" >nul 2>nul"
            if ($LASTEXITCODE -ne 0) { cmd /c "mklink /J `"$link`" `"$Target\.cursor\skills`" >nul" }
            if ($LASTEXITCODE -ne 0) { throw 'Could not link .claude/skills' }
        } else {
            New-Item -ItemType SymbolicLink -Path $link -Target '../.cursor/skills' | Out-Null
        }
        Write-Host '  link        created (.claude/skills -> .cursor/skills)'
    }

    # 5. Keep the link out of git (git on Windows checks symlinks out as text files).
    $gi = Join-Path $Target '.gitignore'
    $entry = '.claude/skills'
    $lines = @()
    if (Test-Path -LiteralPath $gi) { $lines = @(Get-Content -LiteralPath $gi) }
    if ($lines -notcontains $entry) {
        $prefix = ''
        if (Test-Path -LiteralPath $gi) {
            $raw = [IO.File]::ReadAllText($gi)
            if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { $prefix = "`n" }
        }
        [IO.File]::AppendAllText($gi, "$prefix# ProjectKit: local link to .cursor/skills (recreate with scripts/bootstrap)`n$entry`n")
        Write-Host '  gitignore   added .claude/skills'
    }

    Write-Host 'Done.'
} finally {
    if ($Tmp) { Remove-Item -Recurse -Force -LiteralPath $Tmp -ErrorAction SilentlyContinue }
}
