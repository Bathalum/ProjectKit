# ProjectKit bootstrap -- instantiate or refresh the kit in a project directory.
#
# One command, from the project root (no clone of ProjectKit needed):
#   Claude Code: & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1))) claude
#   Cursor:      & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1))) cursor
#   Both:        irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex
#
# Or from a local kit / a repo created from the template:
#   powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1 [claude|cursor|both] [target-dir]
#
# Tools:
#   claude  .claude/skills/ (real folder) + CLAUDE.md -> AGENTS.md
#   cursor  .cursor/skills/ + .cursor/wiki-root (Cursor reads AGENTS.md natively)
#   both    .cursor/skills/ (SSOT) + CLAUDE.md + .claude/skills link (git-ignored)   [default]
#   all     + .gitattributes (*.sh LF, *.ps1 CRLF) so skill scripts run after a Windows checkout
#           + .gitignore <tool-dir>/brainstorm/ (visual-companion scratch sessions)
#
# Idempotent. Kit-owned skills are refreshed; AGENTS.md, the wiki and CLAUDE.md
# are created only when missing -- never overwritten.

# Own scope: `irm | iex` runs in the caller's session -- keep preferences,
# functions and variables from leaking into it.
& {
$ErrorActionPreference = 'Stop'
$RepoUrl = 'https://github.com/Bathalum/ProjectKit.git'
$RawPs = 'https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1'
$RawSh = 'https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh'
$IgnoreComment = '# ProjectKit: local link to .cursor/skills (recreate with scripts/bootstrap)'
$IgnoreEntry = '.claude/skills'
$BrainstormComment = '# ProjectKit: brainstorm visual-companion sessions (mockups, server logs)'
$GitAttributesComment = '# ProjectKit: keep skill scripts runnable on Windows checkouts'
$GitAttributes = @('*.sh text eol=lf', '*.ps1 text eol=crlf')
$OnWindows = ($PSVersionTable.PSEdition -ne 'Core') -or $IsWindows

# Append the lines missing from a text file (created if absent) under one
# comment; existing lines are kept. Returns the lines that were added.
function Add-MissingLines([string]$Path, [string]$Comment, [string[]]$Lines) {
    $have = @()
    if (Test-Path -LiteralPath $Path) { $have = @(Get-Content -LiteralPath $Path | ForEach-Object { $_.Trim() }) }
    $missing = @($Lines | Where-Object { $have -notcontains $_ })
    if ($missing.Count -eq 0) { return @() }
    $prefix = ''
    if (Test-Path -LiteralPath $Path) {
        $raw = [IO.File]::ReadAllText($Path)
        if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { $prefix = "`n" }
    }
    [IO.File]::AppendAllText($Path, "$prefix$Comment`n" + ($missing -join "`n") + "`n")
    return $missing
}

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
    foreach ($f in @((Join-Path $Root '.cursor\wiki-root'), (Join-Path $Root '.claude\wiki-root'))) {
        if (Test-Path -LiteralPath $f) {
            foreach ($line in Get-Content -LiteralPath $f) {
                $t = $line.Trim()
                if ($t -and -not $t.StartsWith('#')) { return ($t -replace '\\', '/').TrimEnd('/') }
            }
        }
    }
    return 'docs'
}

function Write-Utf8([string]$Path, [string]$Text) {
    [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding $false))
}

function Get-OneLiners([string]$T) {
    if ($T -eq 'both') { $ps = "irm $RawPs | iex"; $sh = "curl -fsSL $RawSh | bash" }
    else { $ps = "& ([scriptblock]::Create((irm $RawPs))) $T"; $sh = "curl -fsSL $RawSh | bash -s -- $T" }
    return "- PowerShell: ``$ps```n- bash: ``$sh``"
}

# Remove a directory link (symlink or junction) without touching its target.
function Remove-DirLink([string]$Path) {
    if ($OnWindows) { cmd /c "rmdir `"$Path`"" } else { & /bin/rm -- $Path }
    if ($LASTEXITCODE -ne 0) { throw "Could not remove link $Path" }
}

$Tool = 'both'
$rest = @($args)
if ($rest.Count -gt 0 -and @('claude', 'cursor', 'both') -contains $rest[0]) {
    $Tool = $rest[0]
    $rest = @($rest | Select-Object -Skip 1)
}
$Target = if ($rest.Count -gt 0) { (Resolve-Path -LiteralPath $rest[0]).Path } else { (Get-Location).Path }

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

    Write-Host "ProjectKit ($Tool) -> $Target"
    $gi = Join-Path $Target '.gitignore'

    # 1. Skills: kit owns them -- refresh (extra project-local skills are kept).
    $srcSkills = Join-Path $Src '.cursor\skills'
    $skillsRel = if ($Tool -eq 'claude') { '.claude\skills' } else { '.cursor\skills' }
    $dstSkills = Join-Path $Target $skillsRel
    if ($Tool -eq 'claude') {
        $existing = Get-Item -LiteralPath $dstSkills -Force -ErrorAction SilentlyContinue
        if ($existing -and $existing.LinkType) {
            Remove-DirLink $dstSkills
            Write-Host '  link        removed (.claude/skills is now a real folder)'
        }
    }
    if ((Resolve-Path -LiteralPath $srcSkills).Path -ne $dstSkills) {
        Copy-Tree $srcSkills $dstSkills $true
        Write-Host "  skills      refreshed ($($skillsRel -replace '\\', '/'))"
    }
    if ($Tool -ne 'claude') {
        $wr = Join-Path $Target '.cursor\wiki-root'
        if (-not (Test-Path -LiteralPath $wr)) { Copy-Item -LiteralPath (Join-Path $Src '.cursor\wiki-root') -Destination $wr }
    }

    # 2. Law + wiki: project owns them -- add only what is missing.
    $wikiRoot = Get-WikiRoot $Target   # '/'-separated: also written into CLAUDE.md
    $cut = $wikiRoot.LastIndexOf('/')
    $agentsRel = if ($cut -gt 0) { $wikiRoot.Substring(0, $cut) + '/AGENTS.md' } else { 'AGENTS.md' }
    $agentsPath = Join-Path $Target $agentsRel
    # Monorepo: create the package dir AGENTS.md lives in.
    New-Item -ItemType Directory -Force -Path (Join-Path $Target $wikiRoot) | Out-Null
    if (-not (Test-Path -LiteralPath $agentsPath)) {
        Copy-Item -LiteralPath (Join-Path $Src 'Constitution\AGENTS.md') -Destination $agentsPath
        Write-Host "  law         created ($agentsRel)"
    }
    Copy-Tree (Join-Path $Src 'Constitution\docs') (Join-Path $Target $wikiRoot) $false
    Write-Host "  wiki        missing stubs added ($wikiRoot/)"

    # 3. Claude Code bridge: CLAUDE.md thin pointer (AGENTS.md "Tool bridge").
    $claudeMd = Join-Path $Target 'CLAUDE.md'
    if ($Tool -ne 'cursor' -and -not (Test-Path -LiteralPath $claudeMd)) {
        $skillsNote = if ($Tool -eq 'claude') {
            "Kit skills live in ``.claude/skills/`` (from ProjectKit). To refresh them or repair a missing piece, run from the repo root:"
        } else {
            "Kit skills live in ``.cursor/skills/`` (SSOT). ``.claude/skills`` is a local link to it and is git-ignored.`nIf ``.claude/skills`` is missing (fresh clone), run from the repo root:"
        }
        $text = "# CLAUDE.md`n`nThin pointer -- the law lives in [``$agentsRel``](./$agentsRel) (SSOT). Do not fork rules here.`n`n@$agentsRel`n`n## Skills`n`n$skillsNote`n`n$(Get-OneLiners $Tool)`n"
        Write-Utf8 $claudeMd $text
        Write-Host '  claude      created (CLAUDE.md -> AGENTS.md)'
    }

    # 4. both: .claude/skills -> .cursor/skills (link, not a copy), git-ignored.
    if ($Tool -eq 'both') {
        $linkDir = Join-Path $Target '.claude'
        $link = Join-Path $linkDir 'skills'
        $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
        if ($existing -and $existing.LinkType) {
            Write-Host '  link        ok (.claude/skills)'
        } elseif ($existing) {
            Write-Warning '.claude/skills is a real folder -- left alone. Move its skills into .cursor/skills and re-run.'
        } else {
            if (-not (Test-Path -LiteralPath $linkDir)) { New-Item -ItemType Directory -Path $linkDir | Out-Null }
            if ($OnWindows) {
                # Relative symlink needs Developer Mode/admin; junction works for everyone.
                cmd /c "mklink /D `"$link`" `"..\.cursor\skills`" >nul 2>nul"
                if ($LASTEXITCODE -ne 0) { cmd /c "mklink /J `"$link`" `"$Target\.cursor\skills`" >nul" }
                if ($LASTEXITCODE -ne 0) { throw 'Could not link .claude/skills' }
            } else {
                New-Item -ItemType SymbolicLink -Path $link -Target '../.cursor/skills' | Out-Null
            }
            Write-Host '  link        created (.claude/skills -> .cursor/skills)'
        }

        # git on Windows checks symlinks out as text files -- keep the link per-machine.
        if ((Add-MissingLines $gi $IgnoreComment @($IgnoreEntry)).Count -gt 0) {
            Write-Host '  gitignore   added .claude/skills'
        }
    } elseif ($Tool -eq 'claude' -and (Test-Path -LiteralPath $gi)) {
        # Real skills folder now -- it must not stay git-ignored.
        $lines = @(Get-Content -LiteralPath $gi)
        $kept = @($lines | Where-Object { $_ -ne $IgnoreEntry -and $_ -ne $IgnoreComment })
        if ($kept.Count -ne $lines.Count) {
            if ($kept.Count -gt 0) { Write-Utf8 $gi (($kept -join "`n") + "`n") } else { Remove-Item -LiteralPath $gi }
            Write-Host '  gitignore   removed .claude/skills'
        }
    }

    # 5. Brainstorm sessions (mockups, server logs) are scratch -- keep them out of git.
    $bsDirs = switch ($Tool) { 'claude' { @('.claude/brainstorm/') } 'cursor' { @('.cursor/brainstorm/') } default { @('.cursor/brainstorm/', '.claude/brainstorm/') } }
    $added = @(Add-MissingLines $gi $BrainstormComment $bsDirs)
    if ($added.Count -gt 0) { Write-Host "  gitignore   added $($added -join ', ')" }

    # 6. Line endings: skill .sh scripts break in bash if a Windows checkout makes them CRLF.
    $added = @(Add-MissingLines (Join-Path $Target '.gitattributes') $GitAttributesComment $GitAttributes)
    if ($added.Count -gt 0) { Write-Host "  gitattrib   added $($added -join ', ')" }

    # 7. Leftovers from the other tool are reported, never deleted.
    if ($Tool -eq 'claude' -and (Test-Path -LiteralPath (Join-Path $Target '.cursor'))) {
        Write-Host '  note        .cursor/ exists -- delete it if this project does not use Cursor'
    }
    if ($Tool -eq 'cursor' -and ((Test-Path -LiteralPath $claudeMd) -or (Test-Path -LiteralPath (Join-Path $Target '.claude\skills')))) {
        Write-Host '  note        CLAUDE.md / .claude/skills exist -- delete them if this project does not use Claude Code'
    }

    Write-Host 'Done.'
} finally {
    if ($Tmp) { Remove-Item -Recurse -Force -LiteralPath $Tmp -ErrorAction SilentlyContinue }
}
} @args
