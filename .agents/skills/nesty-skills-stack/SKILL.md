---
name: nesty-skills-stack
description: >-
  Curated agent skills stack for the NestyAI ecosystem. Routes tasks to the
  right installed skill (React, design, browser automation, Postgres, Cloudflare,
  Redis, SEO, code review). Use when setting up skills, onboarding agents, or
  when the user asks which skill to use for a task. Install with scripts/install-all.ps1.
---

# NestyAI Agent Skills Stack

Curated skills for full-stack web, mobile, design, data, infra, and marketing work in this ecosystem.

## Before Any Task: Pick the Right Skill

Read the installed skill that best matches the task. If none is installed, run the install commands below first.

| Task | Skill | Install command |
|------|-------|-----------------|
| React/Next.js performance, data fetching, bundles | `vercel-react-best-practices` | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices` |
| Component APIs, compound components, render props | `vercel-composition-patterns` | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-composition-patterns` |
| React Native / Expo mobile apps | `vercel-react-native-skills` | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-native-skills` |
| UI review, accessibility, UX audit | `web-design-guidelines` | `npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines` |
| Distinctive visual design (new UI) | `frontend-design` | `npx skills add https://github.com/anthropics/skills --skill frontend-design` |
| Landing pages, portfolios, anti-slop redesigns | `design-taste-frontend` | Already in `.agents/skills/design-taste-frontend` |
| Mobile app design via Sleek | `sleek-design-mobile-apps` | `npx skills add sleekdotdesign/agent-skills --skill sleek-design-mobile-apps` |
| Tailwind UI consistency, a11y, SEO meta, motion perf | `baseline-ui`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance` | `npx skills add ibelick/ui-skills` |
| Brainstorm before building features | `brainstorming` | `npx skills add obra/superpowers --skill brainstorming` |
| Browser automation, screenshots, form fill, QA | `agent-browser` | `npx skills add vercel-labs/agent-browser` |
| Browser-use library / cloud automation | `browser-use` (+ `cloud`, `open-source` as needed) | `npx skills add browser-use/browser-use` |
| Postgres query/schema optimization | `supabase-postgres-best-practices` | `npx skills add supabase/agent-skills --skill supabase-postgres-best-practices` |
| Cloudflare Workers, Pages, R2, D1, AI | all Cloudflare skills | `npx skills add cloudflare/skills` |
| Redis data modeling, vectors, caching, security | all Redis skills | `npx skills add redis/agent-skills` |
| SEO audit, technical SEO, rankings | `seo-audit` | `npx skills add coreyhaines31/marketingskills --skill seo-audit` |
| Senior code review of git changes | `code-review-expert` | `npx skills add sanyuan0704/code-review-expert` |
| GSAP animation (React/Next.js, timelines, scroll) | `gsap-react`, `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger` | `npx skills add https://github.com/greensock/gsap-skills -y` (installs to `.agents/skills/` at repo root) |
| Nesty Console v0.8.4 release work | `nesty-console-v084` | Already in `NestyConsole/.agents/skills/nesty-console-v084` |

## Routing Rules

1. **Creative work** (new feature, component, behavior change) → read `brainstorming` first, then the domain skill.
2. **React web** → `vercel-react-best-practices`; architecture refactors → add `vercel-composition-patterns`.
3. **React Native** → `vercel-react-native-skills`, not the web React skill.
4. **Visual design** → `design-taste-frontend` for landing/portfolio/redesign; `frontend-design` for general UI; `sleek-design-mobile-apps` for native mobile design.
5. **UI audit** → `web-design-guidelines` for holistic review; `ibelick/ui-skills` for targeted fixes (a11y, meta, motion, Tailwind).
6. **Browser tasks** → prefer `agent-browser` (Vercel CLI); use `browser-use` for its SDK/cloud stack.
7. **Database** → Postgres/Supabase → `supabase-postgres-best-practices`; full Supabase products → also install `supabase` from same repo.
8. **Infra** → Cloudflare → `cloudflare/skills`; Redis → `redis/agent-skills`.
9. **Marketing/SEO** → `seo-audit` for audits; other marketing skills available in `coreyhaines31/marketingskills`.
10. **Code review** → `code-review-expert` for diff review before merge.
11. **GSAP / UI motion** → `gsap-react` for Next.js; add `gsap-core`, `gsap-timeline`, `gsap-scrolltrigger`, `gsap-performance` as needed. Respect `prefers-reduced-motion`.
12. **Nesty Console releases** → `nesty-console-v084` when building v0.8.4 (deep-link continuity, copy link, optional GSAP polish).

## Install All Skills

From the repo root, run:

```powershell
.\.agents\skills\nesty-skills-stack\scripts\install-all.ps1
```

Or install individually with the commands below (verbatim):

```bash
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices
npx skills add https://github.com/anthropics/skills --skill frontend-design
npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines
npx skills add obra/superpowers --skill brainstorming
npx skills add vercel-labs/agent-browser
npx skills add browser-use/browser-use
npx skills add supabase/agent-skills --skill supabase-postgres-best-practices
npx skills add cloudflare/skills
npx skills add redis/agent-skills
npx skills add vercel-labs/agent-skills --skill vercel-composition-patterns
npx skills add vercel-labs/agent-skills --skill vercel-react-native-skills
npx skills add sleekdotdesign/agent-skills --skill sleek-design-mobile-apps
npx skills add ibelick/ui-skills
npx skills add coreyhaines31/marketingskills --skill seo-audit
npx skills add sanyuan0704/code-review-expert
npx skills add https://github.com/greensock/gsap-skills -y
```

Add `-y` to skip prompts. Add `-g` for global (user-level) install instead of project-level.

## Verify Installation

```bash
npx skills list
npx skills check
npx skills update
```

Browse more skills at https://skills.sh/
