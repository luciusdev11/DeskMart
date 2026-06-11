# Install the NestyAI curated agent skills stack (project scope).
# Run from repo root: .\.agents\skills\nesty-skills-stack\scripts\install-all.ps1

$ErrorActionPreference = "Stop"

$commands = @(
    "npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices -y",
    "npx skills add https://github.com/anthropics/skills --skill frontend-design -y",
    "npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines -y",
    "npx skills add obra/superpowers --skill brainstorming -y",
    "npx skills add vercel-labs/agent-browser -y",
    "npx skills add browser-use/browser-use -y",
    "npx skills add supabase/agent-skills --skill supabase-postgres-best-practices -y",
    "npx skills add cloudflare/skills -y",
    "npx skills add redis/agent-skills -y",
    "npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-composition-patterns -y",
    "npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-native-skills -y",
    "npx skills add sleekdotdesign/agent-skills --skill sleek-design-mobile-apps -y",
    "npx skills add ibelick/ui-skills -y",
    "npx skills add coreyhaines31/marketingskills --skill seo-audit -y",
    "npx skills add sanyuan0704/code-review-expert -y",
    "npx skills add https://github.com/greensock/gsap-skills -y"
)

foreach ($cmd in $commands) {
    Write-Host "`n>> $cmd" -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed (exit $LASTEXITCODE): $cmd"
    }
}

Write-Host "`nDone. Run 'npx skills list' to verify." -ForegroundColor Green
