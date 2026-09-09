# Codex P06 -- Three futures

- Model: GPT-5.6 Sol (Codex)
- Runner: Codex desktop
- Date: 2026-09-03
- Repository baseline: `5917721b4199` (`Prompt 1: Codex market survey`)
- Prompt ID: P06
- Web access used: No
- Input files/context: WolfBite product paragraph supplied in the prompt

## Exact prompt

```text
Our product:

WolfBite is a cross-platform Flutter/Firebase shopping assistant for WIC
participants. It lets authenticated shoppers identify products through barcode
scanning or manual UPC entry, review nutrition information, compare healthier
alternatives, manage a basket against WIC category allowances, import products
recognized from receipts, review benefit balances, and generate a QR-based
checkout handoff. Project 1a found that the application has useful shopping and
benefit-management features but also has inconsistent behavior around
eligibility, shopper-paid overflow, missing nutrition data, receipt importing,
persistence failures, and checkout interoperability.

Propose three versions: SAFE (obvious next step), BOLD (a real bet), and
WILD (probably wrong, but instructive). For each:
- Elevator pitch, two sentences.
- What four students could build AND test of it in one month.
- The biggest risk.
- The kill signal: "we abandon this version if we see ___."

Do not blend them into one compromise. Keep the three futures distinct.
```

## Complete raw response

### SAFE -- Trustworthy product eligibility

**Elevator pitch.** WolfBite becomes a dependable in-store product checker that
reports an item as eligible, ineligible, or unknown instead of presenting
uncertain data as fact. Every result shows its source and freshness, and the
shopper can recover through manual UPC entry when scanning or data access fails.

**One-month build-and-test slice.** Four students could narrow the application
to barcode/manual UPC lookup, explicit three-state eligibility, source and
last-updated labels, cached test data, and clear degraded-mode messages. They
could test the decision logic with versioned product fixtures, cover malformed
and missing data, exercise persistence and offline transitions, and run a small
task-based usability evaluation comparing the revised result screen with the
current behavior.

**Biggest risk.** A polished interface around synthetic or incomplete product
data may improve clarity without proving that the answer is correct in a real
state WIC program.

**Kill signal.** We abandon this version if we see more than one of five
task-based evaluation participants interpret an `unknown` or stale result as
an authoritative eligibility decision.

### BOLD -- Explainable WIC trip planner

**Elevator pitch.** WolfBite shifts from checking one product at a time to
planning a benefit-aware shopping trip before the shopper reaches checkout. It
builds an explainable basket from a household's remaining category allowances
and proposes valid substitutions when an item is unavailable or exceeds an
allowance.

**One-month build-and-test slice.** Four students could build a deterministic
planning engine around one documented, synthetic benefit schema and a small
versioned product catalog; add screens for a benefit profile, planned basket,
rule explanation, and substitute selection; and explicitly exclude live EBT,
inventory, and payment integration. They could test rule invariants,
category/package constraints, boundary conditions, repeatability, and
accessibility, then evaluate whether users can understand why each item or
substitute was selected.

**Biggest risk.** The planner could provide confident but invalid guidance when
real program rules, approved-product lists, household benefits, or store
availability differ from the controlled test data.

**Kill signal.** We abandon this version if we see any recommended basket in
the held-out rule suite violate an encoded benefit, category, or package-size
constraint.

### WILD -- Community WIC shelf map

**Elevator pitch.** WolfBite becomes a community-maintained map showing where
shoppers recently found WIC-eligible products on store shelves. Instead of
promising retailer inventory integration, it treats every sighting as
time-limited evidence that other shoppers can confirm or challenge.

**One-month build-and-test slice.** Four students could prototype a closed pilot
covering a small fixed store list, with manual or scanned UPC sightings,
timestamps, confidence labels, confirmations, stale-entry expiration, and a
moderation queue; no claim would be made that a sighting proves current stock or
eligibility. They could test duplicate and malicious submissions, expiry and
ranking logic, location-privacy boundaries, accessibility, and the effort
required to keep a seeded set of sightings useful during a short pilot.

**Biggest risk.** The product has a severe cold-start and trust problem: without
enough independent, recent contributions, its map is empty or misleading.

**Kill signal.** We abandon this version if we see fewer than 70% of 30 seeded
product sightings independently confirmed or refreshed within seven days of a
closed pilot without the development team supplying the updates.
