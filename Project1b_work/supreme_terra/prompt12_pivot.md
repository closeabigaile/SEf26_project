# Prompt 12 - The Pivot Question

## Prompt
Forget our current plan for a moment. Here are the facts, nothing else:

- The team: four graduate students, roughly ten hours each per week.
- The budget: one month to build AND test a working product.
- What we learned in Project 1a: We worked with an existing WIC-focused grocery shopping application, learned how its use cases map to the codebase, wrote and executed automated tests against those use cases, identified behavior and edge cases, and used Git/GitHub branches and pull requests to combine team work. We also used multiple LLMs to analyze requirements and testing evidence.

Team skills, stated honestly:
- All team members have demonstrated experience reading an unfamiliar software project, working from use cases, running and writing tests, using Git/GitHub, and working with LLM-assisted software engineering.
- The team has experience with general software development, but we should not assume expertise in state WIC infrastructure, payment systems, or government integrations.

Question: is there a DIFFERENT kind of project we should be exploring — one we have not considered because we anchored on the Project 1a product?

Propose three genuinely different project kinds (different domain, different user, or different form: CLI vs web vs library vs bot). For each:
- Why THIS team, specifically, would be unusually good at it.
- What one-month build-and-test slice looks like.
- What we lose by walking away from our current plan.

Then answer plainly: stay the course, or pivot? One paragraph. No hedging.

Hard constraint: we are four graduate students with one month to build AND test the next version of this product.


## Terra Output
•  Project kind                                 Use-case-to-regression-test CLI for web applications
   Why this team would be unusually good at it  Your demonstrated strength is translating use cases into executable tests against an unfamiliar
                                                codebase. That is the core product, not merely a development activity.
   One-month build-and-test slice               A CLI that accepts structured use cases plus a target app URL, generates editable Playwright test
                                                drafts, runs them, and produces a failure report with screenshots and steps. Test it on the
                                                Project 1a app plus one small open-source web app.
   What you lose by leaving the WIC plan        A direct consumer-facing mission and the chance to improve a familiar WIC product.
  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   Project kind                                 Pull-request evidence bot for student or small-team repositories
   Why this team would be unusually good at it  You have real branch/PR workflow experience and have used LLMs to analyze requirements and testing
                                                evidence. Most student teams lack disciplined, evidence-based PR review.
   One-month build-and-test slice               A GitHub Action or local CLI that reads a PR diff, links changed behavior to supplied use cases,
                                                identifies missing/affected tests, and writes a concise review report. Test it on seeded PRs from
                                                the existing project history.
   What you lose by leaving the WIC plan        Barcode, basket, OCR, and user-facing grocery-workflow work; the buyer becomes developers rather
                                                than shoppers.
  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   Project kind                                 Bug-report-to-reproduction web tool for QA teams or open-source maintainers
   Why this team would be unusually good at it  You already know how to turn observed edge cases into automated tests. This makes that skill
                                                accessible to someone who cannot write tests.
   One-month build-and-test slice               A simple web app where a tester submits browser, steps, expected/actual behavior, and screenshots;
                                                it outputs a structured bug report and a Playwright reproduction-test draft. Validate quality
                                                against 10–15 known bugs or seeded scenarios.
   What you lose by leaving the WIC plan        The WIC domain knowledge you have already accumulated and a tangible shopping-assistant demo.

  Pivot. Build the use-case-to-regression-test CLI. It is the strongest match to what all four of you have demonstrably done, avoids pretending to
  have WIC, payment, OCR, or government-integration expertise, and has a credible one-month boundary: support a narrow structured input format,
  one browser-test framework, deterministic report output, and evaluation on known use cases. The WIC assistant is a plausible product idea, but
  under this team’s actual time and skill constraints it invites fragile claims about eligibility, balances, checkout, and sensitive data; the
  testing CLI converts your proven Project 1a capability into the product itself.


## Initial Analysis Notes
- Terra recommends pivoting away from the WIC application rather than extending it.
- Its strongest proposed direction is a use-case-to-regression-test CLI because it directly builds on the team's demonstrated Project 1a experience.
- Terra argues that continuing the WIC product creates risks involving eligibility accuracy, benefit balances, payment systems, OCR, privacy, and government integrations.
- The proposed CLI has a clearer one-month scope, but pivoting would mean losing the WIC domain knowledge and consumer-facing work already completed.
- This recommendation should be compared against the other LLMs before the team decides whether to stay or pivot.