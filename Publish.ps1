$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$owner = 'lijunnankman'
$repo = 'lijunnankman.github.io'
$fullName = "$owner/$repo"
$origin = "https://github.com/$fullName.git"

function Find-Command([string] $name, [string] $fallback) {
    $found = Get-Command $name -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    throw "Required tool '$name' was not found. Install it, then run Publish.cmd again."
}

function Run([string] $description, [scriptblock] $command) {
    Write-Host "`n==> $description" -ForegroundColor Cyan
    & $command
    if ($LASTEXITCODE -ne 0) { throw "$description failed (exit code $LASTEXITCODE)." }
}

function Test-External([scriptblock] $command) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $command *> $null
        return ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = $previous
    }
}

try {
    $git = Find-Command 'git' 'C:\Program Files\Git\cmd\git.exe'
    $gh = Find-Command 'gh' 'C:\Program Files\GitHub CLI\gh.exe'

    # The owner has approved publishing the current sample content.
    if (Select-String -LiteralPath (Join-Path $PSScriptRoot '_config.yml') -SimpleMatch -Pattern 'YOUR NAME' -Quiet) {
        Write-Host 'Publishing the current sample content as requested.' -ForegroundColor Yellow
    }

    # A local build catches YAML and Liquid mistakes before the push, when Jekyll is available.
    $jekyll = Get-Command 'jekyll' -ErrorAction SilentlyContinue
    $jekyllPath = if ($jekyll) { $jekyll.Source } elseif (Test-Path 'C:\Ruby33-x64\bin\jekyll.bat') { 'C:\Ruby33-x64\bin\jekyll.bat' } else { $null }
    if ($jekyllPath) {
        Run 'Checking the site with Jekyll' { & $jekyllPath build --quiet }
    } else {
        Write-Host 'Jekyll is unavailable; GitHub Pages will build the site after upload.' -ForegroundColor Yellow
    }

    if (-not (Test-External { & $gh auth status --hostname github.com })) {
        Run 'Signing in to GitHub (browser opens)' { & $gh auth login --hostname github.com --git-protocol https --web }
    }
    $signedInAs = (& $gh api user --jq '.login').Trim()
    if ($LASTEXITCODE -ne 0 -or $signedInAs -ne $owner) {
        throw "GitHub CLI is signed in as '$signedInAs'. Sign in as '$owner' before publishing."
    }
    Run 'Setting up GitHub authentication for git' { & $gh auth setup-git }

    if (-not (Test-Path -LiteralPath '.git')) {
        Run 'Initializing local Git repository' { & $git init -b main }
    }
    $branch = (& $git branch --show-current).Trim()
    if ($branch -ne 'main') {
        throw "Current branch is '$branch'. Publish from the main branch."
    }
    if (-not (Test-External { & $git remote get-url origin })) {
        Run 'Setting the GitHub destination' { & $git remote add origin $origin }
    } else {
        $existingOrigin = (& $git remote get-url origin).Trim()
        if ($existingOrigin -ne $origin) {
            throw "The origin remote is '$existingOrigin'. Expected '$origin'. No files were uploaded."
        }
    }

    $author = (& $git config --local user.name)
    if (-not $author) { Run 'Setting commit name' { & $git config --local user.name $owner } }
    $email = (& $git config --local user.email)
    if (-not $email) {
        $id = (& $gh api user --jq '.id').Trim()
        if ($LASTEXITCODE -ne 0 -or -not $id) { throw 'Could not read the GitHub account ID.' }
        Run 'Setting a private commit email' { & $git config --local user.email "$id+$owner@users.noreply.github.com" }
    }

    Run 'Staging site files' { & $git add --all }
    & $git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        Run 'Saving local changes' { & $git commit -m 'Update personal website' }
    } elseif ($LASTEXITCODE -ne 0) {
        throw 'Could not inspect staged changes.'
    } else {
        Write-Host 'No new local changes to commit.'
    }

    if (-not (Test-External { & $gh repo view $fullName --json nameWithOwner --jq '.nameWithOwner' })) {
        Run 'Creating the public GitHub Pages repository' {
            & $gh repo create $fullName --public --description 'Personal website'
        }
    } else {
        $isPrivate = (& $gh repo view $fullName --json isPrivate --jq '.isPrivate').Trim()
        if ($LASTEXITCODE -ne 0) { throw "Could not check the visibility of '$fullName'." }
        if ($isPrivate -eq 'true') { throw "The repository '$fullName' is private. Make it public in GitHub before publishing." }
    }
    Run 'Uploading to GitHub' { & $git push -u origin main }

    if (-not (Test-External { & $gh api "repos/$fullName/pages" })) {
        Run 'Enabling GitHub Pages from the main branch' {
            & $gh api --method POST "repos/$fullName/pages" -f 'build_type=legacy' -f 'source[branch]=main' -f 'source[path]=/' --silent
        }
    } else {
        $pagesSource = (& $gh api "repos/$fullName/pages" --jq '(.source.branch // "") + ":" + (.source.path // "")').Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the GitHub Pages source.' }
        if ($pagesSource -ne 'main:/') {
            Run 'Setting GitHub Pages to the main branch' {
                & $gh api --method PUT "repos/$fullName/pages" -f 'build_type=legacy' -f 'source[branch]=main' -f 'source[path]=/' --silent
            }
        }
    }

    Write-Host "`nUploaded successfully. Site: https://$repo/" -ForegroundColor Green
    Write-Host 'GitHub Pages may take a few minutes to publish the latest change.'
} catch {
    Write-Host "`n$($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
