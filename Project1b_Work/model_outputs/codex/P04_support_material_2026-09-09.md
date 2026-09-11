# Codex P04 -- The support material we have not read yet

Model: GPT-5.6 Sol (Codex)  
Runner: Codex desktop  
Date: 2026-09-09  
Repository commit: `06f9dfe2280d6d1f6556d8e7609821c997c2c165` aka
"Support resources, standards, and licenses info"  
Prompt ID: P04  
Web access used: Yes  
Input files/context: `Project1a_Work/use_cases/usecases_final.md`,
`Project1a_Work/baseline.md`, `Project1b_Work/inputs/product_context.md`,
`Project1b_Work/rivals/validated_rivals.md`, `Project1b_Work/report/main.tex`,
`Project1b_Work/report/references.bib`, `Project3/pubspec.yaml`,
`Project3/LICENSE.md`, `Project3/lib/`, generated package notices, and the
current external sources listed below

## Exact prompt

```text
## Prompt 4 — The Support Material We Have Not Read Yet

We are analyzing and extending **WolfBite**, the software product our team inherited and evaluated during Project 1a for CSC 510. We understand the existing code and documented use cases, but before defining the final scope of Project 2, we need to understand the external rules, standards, licenses, domain knowledge, and human factors that could affect the product.

This task is intended to identify **real support material that could influence design, implementation, testing, security, accessibility, or future feature decisions**.

### Source Material

Before beginning:

1. Review the documented **Project 1a (`Proj1a`) use cases, actors, workflows, requirements, architecture, dependencies, and implementation**.
2. Use the **20 finalized Project 1a use cases** as the authoritative source for WolfBite's existing functionality.
3. Review relevant **Project 1b (`Proj1b`) documentation**, including market analysis, competitor research, proposed Project 2 directions, and milestone/support-material work if available.
4. Identify WolfBite's actual application domain, users, data handled, dependencies, and workflows from the project documentation.
5. Do **not** assume the project belongs to a regulated domain unless the documentation supports that conclusion.
6. Do not modify any project files. This task is analysis only.

When identifying support material, use **real, findable, authoritative sources**. Prefer official standards bodies, government agencies, dependency licenses, professional organizations, and primary documentation.

---

### 1. Product and Domain Context

Begin with a concise summary:

**Product:** WolfBite

**Primary Domain:**
[Identify the domain based on Project 1a documentation.]

**Primary Users / Actors:**
[List the documented actors or user groups.]

**Relevant Data / Information Handled:**
[Summarize the important categories of data the application stores, processes, or displays.]

**Important Technical Characteristics:**
[Briefly identify relevant technologies, dependencies, authentication, databases, APIs, external services, etc.]

**Likely Project 2 Direction:**
[Summarize the current direction from Project 1b documentation if one exists. If not yet finalized, state that.]

Keep this section grounded in the project files.

---

### 2. Long List of Relevant Support Material

Create a **broad and detailed list** of support material that could reasonably affect WolfBite or its Project 2 extension.

Consider at minimum:

* Laws and regulations
* Privacy and data protection
* Consumer protection
* Accessibility requirements
* Cybersecurity standards and guidance
* Software-development standards
* Dependency and software licenses
* Data/API licenses
* Domain-specific professional guidance
* User safety or trust considerations
* Human factors
* Team/workload implications
* Usability and interface guidance
* Authentication and account-management guidance
* Data retention and deletion practices
* Relevant state or federal requirements
* Relevant ISO, IEEE, NIST, W3C, OWASP, or similar standards

Do not force categories that clearly do not apply to WolfBite.

For example, do not include medical, financial, food-safety, labor, or other domain-specific regulations unless WolfBite's documented use cases or proposed Project 2 features create a reasonable connection.

Use this table:

| # | Category   | Support Material                               | Source / Organization | Why It Matters to WolfBite | Related Use Cases  | Priority                       |
| - | ---------- | ---------------------------------------------- | --------------------- | -------------------------- | ------------------ | ------------------------------ |
| 1 | [Category] | [Specific law, standard, license, guide, etc.] | [Real source]         | [1–2 sentences]            | [UC numbers/names] | MUST-READ / SHOULD-READ / SKIM |

Create a **long list**, not merely the minimum number of examples.

---

### 3. Laws and Regulations

Identify laws or regulations that may affect the documented WolfBite system or realistic Project 2 extensions.

Consider areas such as:

* Privacy and personal data
* Data collection and storage
* User accounts
* Children's data, if relevant
* Consumer protection
* Electronic communications
* State privacy requirements
* Data breach requirements
* Employment or labor issues, if WolfBite manages worker activity
* Tax or financial rules, if relevant
* Other domain-specific legal requirements

For each item, explain:

* What it governs
* Why it may apply to WolfBite
* Which documented Project 1a use cases it touches
* Whether Project 2 could increase its importance

Do not state that a law definitely applies unless the project evidence supports that conclusion. Distinguish between:

* **Clearly relevant**
* **Potentially relevant**
* **Not currently applicable but relevant if Project 2 adds certain functionality**

---

### 4. Standards and Technical Guidance

Identify technical standards and industry guidance that could affect design or implementation.

At minimum investigate whether the following are relevant:

* **WCAG** accessibility guidance
* **ADA-related accessibility considerations**
* **OWASP** web/mobile application security guidance
* **NIST** security or privacy guidance
* Relevant **ISO standards**
* Relevant **IEEE standards**
* Secure authentication/password guidance
* Secure session management
* Input validation
* API security
* Logging and error handling
* Data backup and recovery
* Usability and human-computer interaction guidance

Use this format:

| Standard / Guidance | Relevant?           | Related UC(s) | Design Impact       | Priority                       |
| ------------------- | ------------------- | ------------- | ------------------- | ------------------------------ |
| [Name]              | YES / POSSIBLY / NO | [UCs]         | [What could change] | MUST-READ / SHOULD-READ / SKIM |

If a commonly known standard does not meaningfully apply, state that rather than forcing it into the recommendation.

---

### 5. Licenses and Dependency Review

Inspect WolfBite's documented dependencies and project configuration.

Identify important licenses associated with:

* Frameworks
* Libraries
* Packages
* SDKs
* Databases
* APIs
* Fonts, images, or other assets
* Third-party data
* Any code inherited from the original project
* Any dependencies that may be introduced by the current Project 2 direction

Use this table:

| Dependency / Resource | License | Current Use | Important Restriction / Obligation | Project 2 Concern | Priority |
| --------------------- | ------- | ----------- | ---------------------------------- | ----------------- | -------- |

Pay particular attention to:

* Attribution requirements
* Redistribution requirements
* Copyleft requirements
* Commercial-use restrictions
* Modification/distribution requirements
* Compatibility between licenses
* Missing or unclear license information

Do not guess a dependency's license. If it cannot be verified, state **UNVERIFIED**.

---

### 6. Domain Knowledge

Identify real domain-specific documentation that would help the team better understand how WolfBite's users actually work.

Examples may include:

* Professional practice guides
* Industry workflow guidance
* Research on user behavior
* Common terminology
* Best-practice guides
* Relevant organizational procedures
* Domain-specific usability expectations

For each source:

**Material:** [Name]

**Source:** [Organization/publication]

**Why we should read it:**
[What it teaches us about WolfBite's users or workflow.]

**Affected use cases:**
[UC numbers and names.]

**Possible Project 2 impact:**
[What design decision it could influence.]

**Priority:** MUST-READ / SHOULD-READ / SKIM

Do not invent domain-specific rules simply because they seem plausible.

---

### 7. Human Factors

Evaluate human-factors material relevant to the way WolfBite affects its users.

Consider topics such as:

* Cognitive load
* Notification overload
* Decision fatigue
* User trust
* Error prevention
* Accessibility
* Onboarding
* Workflow interruption
* Information overload
* User control and reversibility
* Administrative workload
* Managing teams or groups, if applicable
* Fairness or bias in automated recommendations, if applicable
* Whether a proposed Project 2 feature could increase burden on users

For each relevant human-factor topic, identify a real source and connect it to the documented use cases.

Use this table:

| Human-Factor Topic | Source | Related UC(s) | Risk / Opportunity | Design Implication | Priority |
| ------------------ | ------ | ------------- | ------------------ | ------------------ | -------- |

---

### 8. Highest-Priority Reading List

From the complete analysis, identify the **5–10 most important sources** the team should actually read before finalizing Project 2.

Rank them from highest to lowest priority.

Use this table:

| Rank | Source   | Category   | Why It Is High Priority | UC / Project 2 Connection |
| ---- | -------- | ---------- | ----------------------- | ------------------------- |
| 1    | [Source] | [Category] | [Reason]                | [Connection]              |

Only include sources that could realistically affect a design, implementation, testing, legal, security, or accessibility decision.

---

### 9. MUST-READ Summary

Provide:

**Total MUST-READ:** X
**Total SHOULD-READ:** X
**Total SKIM:** X

Then list each **MUST-READ** source using:

#### [Source Name]

**Organization:**
[Organization]

**Official Source / URL:**
[Live URL]

**Why it matters:**
[Short explanation.]

**Affected Project 1a Use Cases:**
[UC numbers/names.]

**Project 2 Decision It Could Change:**
[Specific design, implementation, testing, or scope decision.]

---

### 10. Project 2 Impact

Finish with this table:

| Area               | Most Important Finding | Project 2 Recommendation |
| ------------------ | ---------------------- | ------------------------ |
| Legal / Regulatory | [Finding]              | [Recommendation]         |
| Accessibility      | [Finding]              | [Recommendation]         |
| Security           | [Finding]              | [Recommendation]         |
| Licensing          | [Finding]              | [Recommendation]         |
| Domain Knowledge   | [Finding]              | [Recommendation]         |
| Human Factors      | [Finding]              | [Recommendation]         |

Then provide **3 concise takeaways** describing what the team should account for before finalizing Project 2 scope.

---

### 11. Sources

List the external sources used in the analysis.

For each:

1. **Source:** [Name]
   **Organization:** [Organization]
   **URL:** [Live URL]
   **Type:** Law / Regulation / Standard / License / Domain Guidance / Human Factors
   **Priority:** MUST-READ / SHOULD-READ / SKIM

Only include sources that were actually reviewed or verified.

---

### Important Rules

* Use the **20 documented use cases within `Proj1a`** as the authoritative source for WolfBite's current functionality.
* Use `Proj1b` documentation to understand the team's proposed direction for Project 2.
* Do not ask for the use cases to be pasted if they already exist in the repository.
* Do not modify any files.
* Do not invent laws, regulations, standards, licenses, URLs, or professional guidance.
* Use real and findable sources.
* Prefer official and primary sources over blogs or summaries.
* Connect every recommended source to a **specific documented WolfBite use case, workflow, technical component, or Project 2 direction**.
* Do not include an item merely because it is generally important in software engineering.
* Explain why it matters specifically to WolfBite.
* Do not force unrelated domains such as healthcare, finance, food regulation, or labor law onto WolfBite without evidence from the project.
* Clearly distinguish between requirements that appear mandatory and material that is only best-practice guidance.
* For licenses, verify the actual license rather than assuming one.
* If applicability is uncertain, say so clearly.
* Keep the results organized and consistent so the same prompt can be run through multiple LLMs and compared directly.
```

## Response

Scope note: this is product analysis, not legal advice. “MUST-READ” means the
team should read the source before fixing Project 2 scope; it does not mean every
item is a law that directly binds this student prototype. Applicability depends
on who deploys the product, what data is collected, and whether it is integrated
with an agency, retailer, or payment system.

### 1. Product and Domain Context

**Product:** WolfBite

**Primary Domain:** Consumer-facing WIC grocery-shopping assistance. WolfBite
helps a shopper identify products, inspect nutrition information, compare
alternatives, manage a basket and benefit estimates, scan receipts, and prepare
a checkout handoff. It is an informational shopping aid, not the WIC EBT system,
an authorized benefits ledger, a healthcare provider, or a food seller.

**Primary Users / Actors:** The 20 finalized use cases name a shopper as the
primary actor. Project 1b narrows the audience to WIC participants and
caregivers shopping for households, often while managing young children.
Secondary stakeholders include household benefit recipients, state/local WIC
staff, retailers/cashiers, state IT and EBT processors, authorized-product-list
(APL) maintainers, accessibility and language advocates, privacy/security
reviewers, OCR/data providers, developers, and the course sponsor.

**Relevant Data / Information Handled:** Account name, email, password-managed
identity, address, Firebase user ID, basket contents and quantities, benefit and
shopper-paid estimates, product UPCs, eligibility/category fields, nutrition and
FoodData Central records, receipt photographs and extracted UPC-like numbers,
QR checkout data, timestamps, and application/error telemetry. Receipt images
may expose store, date/time, purchases, benefit/payment clues, and other
household information even when the application does not deliberately extract
those fields.

**Important Technical Characteristics:** The implementation is a cross-platform
Flutter/Dart app using Firebase Authentication and Cloud Firestore. It uses
email/password accounts, local and cloud state, camera/gallery and barcode
packages, HTTP calls, and QR generation. UC10 currently base64-encodes the full
receipt and sends it to OCR.space over HTTPS. Google ML Kit text-recognition
packages are declared but not imported, and several other declared packages are
unused. The app's Firestore data model includes `users/{uid}` and an `apl`
collection. Public Firebase client configuration is not the authorization
boundary; Firebase Authentication and Security Rules are. The ignored
`pubspec.lock` means dependency resolution is not reproducible.

**Likely Project 2 Direction:** Project 1b currently favors a narrow,
item-level explanation-and-recovery flow for the case where an item appears
eligible in the app but is rejected at checkout. The prototype should use fixed
or synthetic mismatch scenarios and rule-based likely causes and next steps. It
should not claim to know an authoritative rejection cause and should not require
live WIC, retailer, POS, APL, or EBT integration. The proposed evaluation asks
whether at least 80% of representative shoppers can choose a sensible next step,
with a 20-percentage-point improvement over a baseline explanation, within 60
seconds.

### 2. Long List of Relevant Support Material

Priorities below are reading priorities for this Project 2 decision. The totals
in Section 9 count these 34 rows exactly.

| # | Category | Support Material | Source / Organization | Why It Matters to WolfBite | Related Use Cases | Priority |
|---:|---|---|---|---|---|---|
| 1 | Federal WIC regulation | [7 CFR §246.10, Supplemental foods](https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.10) | eCFR / USDA | Defines the federal food-package framework. It prevents WolfBite from treating nutrition preference, generic food identity, or app lookup as proof that an item is purchasable with a participant's benefits. | UC5 Identify product; UC6 Review nutrition; UC7 Compare alternatives; UC9 Choose alternative; UC18 Review balances; UC19 Prepare handoff | MUST-READ |
| 2 | State WIC data | [North Carolina WIC Authorized Product List](https://www.ncdhhs.gov/divisions/child-and-family-well-being/community-nutrition-services-section/wic/vendors/nc-wic-authorized-product-list-apl) | NC DHHS | It is the relevant state product-authorization source, includes UPC submission and nutrition criteria, and can change. Project 2 scenarios must distinguish APL status from household benefit availability. | UC5; UC10 Scan receipt; UC11 Add receipt products; UC18; UC19 | MUST-READ |
| 3 | State WIC workflow | [NC WIC Vendor Manual, FFY 2025–2026](https://www.ncdhhs.gov/ffy-2025-2026-vendor-manual-cover/download?attachment=) | NC DHHS | Documents no-override checkout behavior, daily APL downloads, benefit-balance checks, common rejection causes, split tender, receipt content, and escalation. This is the most direct source for an accurate recovery flow. | UC5; UC8 Add product; UC11; UC12 Review basket; UC15 Add shopper-paid quantity; UC18; UC19 | MUST-READ |
| 4 | EBT interoperability | [WIC EBT Technical Implementation Guide and Operating Rules](https://www.fns.usda.gov/wic/ebt/technical-implementation-guide-operating-rules) | USDA FNS | Defines standardized EBT purchase messages and file handling for agencies, vendors, and processors. It sets a boundary: a mocked explanation flow is feasible, but authoritative reason codes would require real ecosystem integration. | UC18; UC19; proposed mismatch flow | SHOULD-READ |
| 5 | Participant confidentiality | [7 CFR §246.26 and USDA confidentiality explanation](https://www.fns.usda.gov/wic/protecting-participant-confidentiality-within-cdc-screening-protocols) | eCFR / USDA FNS | Personally identifying WIC information is subject to disclosure limits in official WIC operations. It is conditional for the independent prototype but becomes central if an agency supplies participant or benefit data. | UC1 Create account; UC4 Resume session; UC18; UC20 Finish session | SHOULD-READ |
| 6 | Consumer protection and privacy | [Marketing Your Mobile App: Get It Right from the Start](https://www.ftc.gov/business-guidance/resources/marketing-your-mobile-app-get-it-right-start) and [App Developers: Start with Security](https://search.ftc.gov/business-guidance/resources/app-developers-start-security) | U.S. FTC | Claims about eligibility, nutrition, privacy, or security must be supportable. The guidance also calls for transparent collection/sharing, data minimization, secure transmission, vendor diligence, and disposal. | UC1–UC20, especially UC5–7, UC10, UC18–19 | MUST-READ |
| 7 | State breach notification | [N.C. Gen. Stat. §75-65](https://library.ncleg.gov/EnactedLegislation/Statutes/HTML/BySection/Chapter_75/GS_75-65.html) | North Carolina General Assembly | May impose notification duties after a qualifying breach involving NC residents' personal information. Whether WolfBite's exact records and operator fall within the definitions requires legal review. | UC1–4; UC10; UC20 | SHOULD-READ |
| 8 | Children's privacy | [COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions) | U.S. FTC | The documented user is an adult shopper/caregiver and the app does not intentionally collect a child's data, so COPPA is not currently indicated. Reassess if the product becomes child-directed or knowingly collects under-13 personal information. | Conditional extension of UC1–4 or household profiles | SKIM |
| 9 | Health privacy | [HIPAA Covered Entities and Business Associates](https://www.hhs.gov/hipaa/for-professionals/covered-entities/index.html) | HHS OCR | Nutrition information is not automatically HIPAA-regulated. WolfBite is not documented as a covered entity or business associate; reassess only if it operates for one and handles protected health information. | Conditional extension of UC1, UC6–7, UC13 | SKIM |
| 10 | Disability access law | [ADA Guidance on Web Accessibility](https://www.ada.gov/resources/web-guidance/) | U.S. DOJ | ADA duties attach to covered public entities and public accommodations, not automatically to every student prototype. A WIC-agency or covered-service deployment would materially increase accessibility obligations. | All user-facing UCs; most critical UC1, UC5, UC10, UC18–19 | SHOULD-READ |
| 11 | Federal digital accessibility | [Section 508 laws and policies](https://www.section508.gov/manage/laws-and-policies/) | U.S. General Services Administration | No present federal procurement or federal-agency deployment is documented. Treat it as a contract/deployment trigger, not a current requirement. | All UCs if federally procured or operated | SKIM |
| 12 | Accessibility standard | [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | W3C | Level AA supplies testable criteria for contrast, non-color cues, target size, labels, errors, suggestions, focus, and authentication. These directly affect scanning, rejected-item explanations, and recovery actions. | UC1–20, especially UC1–2, UC5, UC10, UC14–19 | MUST-READ |
| 13 | Mobile accessibility mapping | [WCAG2ICT 2.2](https://www.w3.org/TR/wcag2ict-22/) | W3C | Informatively maps WCAG concepts to non-web software. It is useful for translating WCAG to Flutter mobile screens but is not an independent conformance standard. | All user-facing UCs | SHOULD-READ |
| 14 | Mobile security | [OWASP Mobile Application Security Verification Standard (MASVS)](https://mas.owasp.org/MASVS/) | OWASP Foundation | Gives a mobile-specific verification baseline for storage, authentication, network traffic, platform interaction, code, resilience, and privacy. It directly covers account, Firestore, receipt-image, and API behavior. | UC1–4; UC10–11; UC18–20 | MUST-READ |
| 15 | Application security | [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/) | OWASP Foundation | Provides testable security requirements for validation, authentication, sessions, access control, logging, and data protection. It can become the security acceptance checklist for app/backend behavior. | UC1–5; UC10–11; UC18–20 | SHOULD-READ |
| 16 | API security | [OWASP API Security Top 10](https://owasp.org/www-project-api-security/) | OWASP Foundation | Broken object authorization, unsafe third-party API consumption, resource exhaustion, and improper inventory are relevant to Firestore queries and the OCR request path. | UC4–5; UC10–11; UC18–20 | SHOULD-READ |
| 17 | Authentication and sessions | [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html) | NIST | Current guidance supports password blocklists, password managers/paste, rate limiting, secure recovery, and explicit session termination. WolfBite's six-character local minimum is not an adequate design target. | UC1 Create account; UC2 Sign in; UC3 Sign out; UC4 Resume; UC20 Finish | MUST-READ |
| 18 | Privacy engineering | [NIST Privacy Framework 1.0](https://www.nist.gov/privacy-framework) | NIST | A voluntary method for inventorying receipt/account data, purposes, processors, retention, user communication, and deletion. It can keep the prototype from collecting data merely because the current code can. | UC1; UC4; UC10–11; UC20 | SHOULD-READ |
| 19 | Secure development lifecycle | [NIST SP 800-218, SSDF 1.1](https://csrc.nist.gov/pubs/sp/800/218/final) | NIST | Helps a student team define repository, dependency, review, secret, vulnerability, and release practices proportionate to the prototype. | Cross-cutting; especially UC1–5, UC10–11, UC18–20 | SHOULD-READ |
| 20 | Logging and error handling | [NIST SP 800-92, Guide to Computer Security Log Management](https://csrc.nist.gov/pubs/sp/800/92/final) | NIST | WolfBite needs enough structured events to diagnose stale APL and service failures without logging passwords, receipt contents, or unnecessary account/benefit data. | UC1–5; UC10–11; UC18–20 | SHOULD-READ |
| 21 | Backup and recovery | [NIST contingency-planning resources / SP 800-34](https://csrc.nist.gov/Topics/Security-and-Privacy/security-programs-and-operations/contingency-planning) | NIST | Cloud/local persistence failures can silently diverge. Even a prototype needs fixture backups, recovery testing, and a clear statement that benefit estimates are not authoritative. | UC4; UC8; UC11–12; UC14–18; UC20 | SHOULD-READ |
| 22 | Software product quality | [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html) | ISO/IEC | Its quality model can turn vague goals into tests for functional suitability, reliability, usability, security, compatibility, maintainability, and safety. | All UCs and Project 2 evaluation | SHOULD-READ |
| 23 | Human-centered design | [ISO 9241-210:2019](https://www.iso.org/standard/77520.html) | ISO | Supports iterative design with real context-of-use evidence. That is especially important for a time-pressured checkout interruption rather than an ordinary browsing screen. | UC5; UC8; UC12; UC18–19; proposed recovery flow | SHOULD-READ |
| 24 | Security management | [ISO/IEC 27001:2022](https://www.iso.org/standard/27001) | ISO/IEC | Full ISMS certification is disproportionate for the course prototype. It becomes relevant if a production operator or public agency requires organizational security controls or procurement evidence. | Organization-wide, conditional production deployment | SKIM |
| 25 | Requirements engineering | [ISO/IEC/IEEE 29148:2018](https://standards.ieee.org/standard/29148-2018.html) | ISO/IEC/IEEE | Helps make the explanation/recovery requirements unambiguous, traceable, testable, and explicit about assumptions and external-interface boundaries. | All UCs; Project 2 mismatch requirements | SHOULD-READ |
| 26 | Cognitive accessibility | [Making Content Usable for People with Cognitive and Learning Disabilities](https://www.w3.org/TR/coga-usable/) | W3C | Supplements WCAG with clear language, error avoidance, memory support, focus, familiar steps, and help—useful for a stressful rejection explanation. It is guidance, not a separate WCAG conformance level. | UC1–2; UC5; UC10; UC12; UC18–19 | SHOULD-READ |
| 27 | WIC app user research | [Mobile App Features Desired by WIC Participants](https://formative.jmir.org/2021/7/e30450/) | JMIR Formative Research | Interviews and card sorting with adult caregivers found demand for balance checking and scanning plus needs for ease, multilingual support, and low-burden performance. This grounds priorities in users rather than competitor feature counts. | UC5; UC10; UC18–19 | MUST-READ |
| 28 | WIC shopping barriers | [Participant perspectives on WIC shopping](https://pubmed.ncbi.nlm.nih.gov/30502034/) | Journal of Nutrition Education and Behavior / PubMed | Qualitative research across four states reports difficulty identifying allowable items and stigma at checkout. It directly supports a private, fast, non-blaming recovery design. | UC5; UC8; UC18–19 | MUST-READ |
| 29 | Recent WIC shopping research | [Fiedler et al., participant perspectives on the WIC shopping experience](https://pubmed.ncbi.nlm.nih.gov/40874893/) | Journal of Nutrition Education and Behavior / PubMed | Offers newer corroboration and should be checked for changes in post-EBT/app shopping burdens before freezing the scenario taxonomy. | UC5; UC8; UC18–19 | SHOULD-READ |
| 30 | Receipt OCR service/privacy | [OCR.space API documentation](https://ocr.space/ocrapi) and [privacy policy](https://ocr.space/privacypolicy) | OCR.space | UC10 sends the entire receipt image to this hosted processor. Its retention, logging, rate limits, service tier, disclosure, consent, and data-processing terms can change whether cloud OCR should remain in scope. | UC10 Scan receipt; UC11 Add receipt products | MUST-READ |
| 31 | Software and asset licensing | Project MIT license, generated notices, and official package license pages | Project authors / Flutter / package authors | Redistribution must retain applicable MIT, BSD, and Apache notices. No reviewed direct dependency was copyleft, but asset provenance and an ignored lockfile create unresolved release risks. | All implemented UCs; distribution of Project 2 | SHOULD-READ |
| 32 | Cloud service controls | [Firebase Security Rules and Authentication](https://firebase.google.com/docs/rules/rules-and-auth), [service terms](https://firebase.google.com/terms), and [data-processing terms](https://firebase.google.com/terms/data-processing-terms) | Google Firebase | Firestore rules, not bundled client config, control access. The operator remains responsible for configuration, credentials, lawful processing, retention, and backups. | UC1–5; UC8; UC11–12; UC14–20 | SHOULD-READ |
| 33 | Automated-system risk | [NIST AI Risk Management Framework 1.0](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10) | NIST | Current Project 2 logic is rule-based and should not be marketed as AI. Read further only if the team makes predictive eligibility, nutrition, or rejection-cause recommendations. | UC6–7; UC9; UC13; conditional Project 2 predictor | SKIM |
| 34 | Nutrition data/API | [FoodData Central API Guide](https://fdc.nal.usda.gov/api-guide/) and [data documentation](https://fdc.nal.usda.gov/data-documentation/) | USDA Agricultural Research Service | FDC data is public-domain/CC0, attribution is requested, API keys should not be public, and branded records change. Missing nutrients cannot safely be converted to zero or used as proof of a healthier product. | UC5–7; UC9; UC13 | SHOULD-READ |

### 3. Laws and Regulations

| Applicability | Law / regulation | What it governs and why it may apply | Project 1a connection | Project 2 effect |
|---|---|---|---|---|
| **Clearly relevant to the product domain; direct duties primarily govern WIC agencies/vendors** | 7 CFR §246.10 | Establishes federal WIC food-package requirements and state-agency responsibilities. WolfBite must represent the rules accurately but must not imply that an informational lookup authorizes a purchase. | UC5–7, UC9, UC18–19 | Scenario labels and explanations must separate product category, APL status, participant balance, size/form restrictions, and live transaction outcome. |
| **Clearly relevant to an NC WIC workflow; direct vendor duties do not automatically bind WolfBite** | NC WIC Vendor Manual and current NC APL | The manual governs authorized vendors and describes how the APL and participant benefit balance affect checkout. It says no overrides are allowed and identifies stale APL, absent APL, absent benefit, and insufficient balance as common causes. | UC5, UC8, UC11–12, UC15, UC18–19 | This should be the authoritative taxonomy for synthetic NC mismatch cases. Do not invent a “force approve” recovery action. |
| **Clearly relevant to a public/commercial release; best-practice baseline for the student prototype** | FTC Act §5 principles reflected in FTC mobile-app guidance and enforcement | Prohibits unfair or deceptive practices. Unsupported “healthy,” “eligible,” “secure,” or causal claims and undisclosed receipt sharing could create risk. | All UCs, especially UC5–7, UC10, UC18–19 | Use calibrated language such as “likely cause” and “check these next steps”; disclose processors and collection; substantiate claims; avoid dark patterns. |
| **Potentially relevant** | N.C. Gen. Stat. §75-65 | Requires notice after certain security breaches involving covered personal information. Whether WolfBite's exact combination of email, credentials, address, receipt, and account records meets every statutory definition is fact-dependent. | UC1–4, UC10, UC20 | A production release needs incident response, data inventory, and legal review; Project 2 should avoid expanding sensitive data. |
| **Potentially relevant for an agency or covered service deployment** | ADA Titles II/III | DOJ guidance explains that covered state/local entities and businesses open to the public have accessibility duties. The current course prototype alone does not establish the operator or deployment facts. | All user-facing UCs | Treat WCAG 2.2 AA as a design/test target now. A state-agency deployment would make mobile accessibility and procurement review more important. |
| **Not currently applicable; relevant if official participant data is added** | 7 CFR §246.26 WIC confidentiality | Limits disclosure/use of personally identifying WIC information within the program. The prototype currently maintains its own app records rather than official WIC records. | UC1, UC4, UC18, UC20 | A live benefit/agency connection would require data-sharing authority, purpose limits, access controls, retention rules, and agency review. |
| **Not currently applicable; relevant if the audience/data model changes** | COPPA | Applies to child-directed online services collecting personal information and general-audience services with actual knowledge of collection from children under 13. Caregivers, not children, are the documented actors. | Conditional UC1–4 household/child profiles | Do not add child profiles, photos, precise location, or direct child accounts without a deliberate COPPA analysis and parental-consent design. |
| **Not currently applicable; relevant if the operator relationship changes** | HIPAA Privacy/Security Rules | HHS explains that HIPAA applies to covered entities and business associates. Food/nutrition data and WIC participation do not, by themselves, make this app a HIPAA system. | Conditional UC1, UC6–7, UC13 | Reassess only if a covered healthcare entity operates WolfBite or sends protected health information under a business-associate relationship. |
| **Not currently applicable; relevant upon federal procurement or operation** | Rehabilitation Act §508 | Applies to federal information and communication technology. No federal-agency use or procurement is documented. | All UCs if procurement context changes | Keep accessibility evidence reusable, but do not claim current Section 508 compliance. |

No documented workflow justifies adding labor law, tax law, food-safety handling
rules, GLBA, or PCI DSS. WolfBite does not manage workers, calculate or collect
tax, prepare/sell food, hold financial-account data, or process a card payment.
The shopper-paid field and QR handoff are estimates/data transfer, not payment
processing. CAN-SPAM/TCPA would need reassessment only if Project 2 adds
marketing email, SMS, or robocalls.

### 4. Standards and Technical Guidance

| Standard / Guidance | Relevant? | Related UC(s) | Design Impact | Priority |
|---|---|---|---|---|
| WCAG 2.2 Level AA | YES | UC1–20; especially UC1–2, UC5, UC10, UC14–19 | Test contrast, color independence, text scaling, focus order, labels, status announcements, error identification/suggestions, 24×24 CSS-pixel minimum targets (or spacing exception), and accessible authentication. | MUST-READ |
| WCAG2ICT 2.2 | YES | All mobile screens | Translate WCAG concepts carefully to native Flutter widgets, platform semantics, touch, and non-web content. Do not describe WCAG2ICT as a separate certification. | SHOULD-READ |
| ADA Title II/III accessibility considerations | POSSIBLY | All UCs | Deployment/operator facts determine the legal duty. Regardless, include screen-reader and keyboard/switch paths and avoid an image-only scanner workflow. | SHOULD-READ |
| Section 508 | NO, currently | All UCs only if federal | Preserve test evidence for possible procurement, but no present federal use is documented. | SKIM |
| OWASP MASVS | YES | UC1–4, UC10–11, UC18–20 | Verify local/cloud storage, authentication, network encryption, platform permissions, secret handling, third-party data flow, and privacy controls. | MUST-READ |
| OWASP ASVS | YES | UC1–5, UC10–11, UC18–20 | Select a small, traceable security requirement set for validation, authorization, sessions, data protection, errors, and logging. | SHOULD-READ |
| OWASP API Security Top 10 | YES | UC4–5, UC10–11, UC18–20 | Threat-model Firestore document authorization, excessive data exposure, OCR request/resource limits, error leakage, and trust in third-party results. | SHOULD-READ |
| NIST SP 800-63B-4 | YES as best practice, not automatically binding | UC1–4, UC20 | Replace the six-character design target; allow long passwords and paste/password managers, screen compromised passwords, rate-limit attempts, secure reset, and terminate sessions reliably. Firebase features must be configured to implement the policy. | MUST-READ |
| Firebase Security Rules guidance | YES | UC1–5, UC8, UC11–12, UC14–20 | Deny by default; authorize each user document by authenticated UID; validate field shape/range; separately govern APL reads/writes; test rules in the emulator. | SHOULD-READ |
| NIST Privacy Framework 1.0 | YES | UC1, UC4, UC10–11, UC20 | Create a data map, purpose and retention rule for each field, processor inventory, deletion behavior, and user notice. Version 1.1 was still an initial public draft, so 1.0 is the final baseline used here. | SHOULD-READ |
| NIST SSDF 1.1 (SP 800-218) | YES | Cross-cutting | Pin/review dependencies, scan secrets, review changes, document releases, triage vulnerabilities, and protect build artifacts. | SHOULD-READ |
| NIST SP 800-92 logging guidance | YES | UC1–5, UC10–11, UC18–20 | Log outcome/error codes and correlation IDs, not raw passwords, tokens, full receipts, or unnecessary benefits. Protect, limit, and delete logs on schedule. | SHOULD-READ |
| NIST SP 800-34 contingency guidance | YES, proportionately | UC4, UC8, UC11–12, UC14–18, UC20 | Back up fixtures/configuration, define recovery objectives for production, test restore, and make local/cloud conflict visible rather than silently diverging. | SHOULD-READ |
| ISO/IEC 25010:2023 | YES | All UCs and evaluation | Build a quality/test matrix covering correctness, reliability, usability, security, compatibility, maintainability, and safety from misleading output. | SHOULD-READ |
| ISO 9241-210:2019 | YES | UC5, UC8, UC12, UC18–19 | Observe the checkout context, prototype with target users, measure task success/time and distress, and iterate rather than validating only screen aesthetics. | SHOULD-READ |
| ISO/IEC 27001:2022 | POSSIBLY, later | Production organization | Certification/ISMS scope is too heavy for Project 2; revisit if an agency/operator procurement requires it. | SKIM |
| ISO/IEC/IEEE 29148:2018 | YES | All UCs; proposed mismatch flow | Specify triggers, inputs, source freshness, uncertainty, exact outputs, manual fallback, privacy constraints, and measurable acceptance criteria with traceability. | SHOULD-READ |
| W3C COGA Content Usable | YES as supplemental guidance | UC1–2, UC5, UC10, UC12, UC18–19 | Use short concrete language, one decision at a time, prominent next actions, undo/back, recognition instead of memory, and reachable human help. | SHOULD-READ |
| NIST AI RMF 1.0 | POSSIBLY, only if predictive AI is added | UC6–7, UC9, UC13; conditional Project 2 | If automated recommendations become predictive, document validity, bias, explainability, monitoring, and human override. The current deterministic prototype should not be labeled AI. | SKIM |
| PCI DSS | NO, currently | None | The app does not capture, store, transmit, or process cardholder data. Adding real in-app card payment would trigger a separate architecture and compliance analysis. | SKIM |

### 5. Licenses and Dependency Review

The review used `pubspec.yaml`, the locally resolved lockfile, generated Flutter
notices, the inherited license, source imports, and official license/terms pages.
Resolved versions are included because a range alone does not identify the
software actually distributed. The lockfile is currently ignored, so a clean
install may resolve different versions.

| Dependency / Resource | License | Current Use | Important Restriction / Obligation | Project 2 Concern | Priority |
|---|---|---|---|---|---|
| Inherited WolfBite source | MIT | Entire inherited application | Preserve copyright and MIT permission/warranty notice in substantial copies. Commercial use and modification are allowed; no copyleft. | Keep the repository license and distinguish third-party notices. | MUST-READ |
| Flutter and Dart SDK | BSD-3-Clause plus bundled third-party notices | App framework/toolchain | Preserve copyright, license, disclaimer, and applicable bundled notices on redistribution; do not use contributor names for endorsement. | Regenerate and ship notices for release artifacts. | SHOULD-READ |
| `firebase_core` 4.13.0, `firebase_auth` 6.5.7, `cloud_firestore` 6.8.0 | BSD-3-Clause for FlutterFire code | Initialization, email/password auth, user/APL storage | Preserve BSD notice. The hosted Firebase service is separately controlled by Google terms and data-processing terms. | Security Rules, billing, retention, region, processor disclosure, and backups are operational obligations, not solved by the OSS license. | MUST-READ |
| `provider` 6.1.5+1 | MIT | Basket/application state | Preserve MIT notice in redistribution. | Low license risk; keep version/notice inventory. | SHOULD-READ |
| `go_router` 16.3.0 | BSD-3-Clause | Navigation | Preserve BSD notice and no-endorsement clause. | Low license risk; route guards still require security review. | SHOULD-READ |
| `http` 1.6.0 | BSD-3-Clause | OCR.space HTTP request | Preserve BSD notice. | The library license does not authorize receipt processing; OCR.space terms/privacy govern that service. | SHOULD-READ |
| `image_picker` 1.2.2 | BSD-3-Clause; generated bundle also includes platform-component notices including Apache-2.0 | Camera/gallery receipt selection | Preserve all notices; Apache-2.0 also carries patent and modification-notice conditions. | Permissions and platform privacy manifests matter in addition to license. | SHOULD-READ |
| `mobile_scanner` 7.4.0 | BSD-3-Clause | Product barcode scanning | Preserve BSD notice and no-endorsement clause. | Confirm camera permission disclosure and scan fallback. | SHOULD-READ |
| `qr_flutter` 4.1.0 | BSD-3-Clause | Checkout QR rendering | Preserve BSD notice. | QR output is not proof of retailer/POS interoperability; avoid that claim. | SHOULD-READ |
| `cupertino_icons` 1.0.9 and `excel` 4.0.6 | MIT | Icons; `excel` is declared but no import was located | Preserve MIT notices. | Remove unused `excel` if not needed; unused code increases inventory and update burden. | SHOULD-READ |
| `google_mlkit_commons` 0.11.1 and `google_mlkit_text_recognition` 0.15.1 | MIT for Flutter wrappers; underlying Google ML Kit subject to Google terms | Declared; no source import located | Preserve wrapper MIT notices and comply with ML Kit terms. Google documents on-device input processing plus certain metrics and requires appropriate disclosure. | On-device OCR may reduce receipt disclosure, but verify platform behavior/terms and implement it before claiming that advantage. | MUST-READ |
| `build_runner` 2.15.1, `fake_async` 1.3.3, `flutter_lints` 5.0.0 | BSD-3-Clause | Development/test tooling; some appear unused | Preserve notices if redistributed in a tool bundle; normally not shipped in the mobile runtime. | Pin versions and remove unused tooling. | SHOULD-READ |
| `mockito` 5.6.4 | Apache-2.0 | Development mocks | Preserve license/NOTICE as applicable; mark modified files; Apache patent terms apply. | Test-only, low release risk unless redistributed. | SHOULD-READ |
| `fake_cloud_firestore` 4.1.1 | BSD-2-Clause in reviewed package notice | Firestore test double | Preserve copyright/license/disclaimer. | The currently resolved combination has shown interface mismatch with `cloud_firestore`; pin a compatible pair and run tests in CI. | MUST-READ |
| OCR.space hosted API | **UNVERIFIED software license; service privacy/API terms verified** | Full receipt image is uploaded by UC10 | A hosted API is not an OSS dependency. Usage limits, privacy/retention, processor terms, acceptable use, and DPA availability govern use; a complete redistribution license is not applicable. | Do not release the current upload path without service-term review, user disclosure/consent, minimization, error/rate-limit handling, and a deletion/retention decision. | MUST-READ |
| USDA FoodData Central data/API | CC0 1.0/public domain; attribution requested | Nutrition/FDC-shaped records in product data | Do not expose an API key; default limits apply; identify FDC as the source and publication date. Public-domain status does not guarantee accuracy or freshness. | Preserve unknown/missing values; store provenance/date; never silently translate missing nutrients to zero. | MUST-READ |
| NC WIC APL data file | **UNVERIFIED** for redistribution/modification license | Firestore `apl` concept and product lookup | Public availability is not the same as a license to redistribute, modify, or brand an app as official. | Ask NC DHHS before bundling/republishing; document update time and avoid “official/current” claims without a refresh process. | MUST-READ |
| `wic-logo.png` asset | **UNVERIFIED** in repository | Displayed in the nutrition-badge screen | No asset-specific provenance or permission notice was found. Government-origin imagery and program marks still require source/use review; do not infer permission from repository MIT text. | Replace with an original neutral asset or obtain/document permission before public distribution; avoid implying USDA/NC endorsement. | MUST-READ |

No copyleft license was found among the reviewed direct dependencies. That is not
a blanket clearance: the generated `NOTICES` file contains transitive terms and
should be regenerated for the exact release. The team should commit the
application lockfile (unless it has a documented reason not to), create a
third-party-notice artifact, and repeat license/security review when dependencies
change.

### 6. Domain Knowledge

#### 6.1 Federal WIC food-package framework

**Material:** 7 CFR §246.10, Supplemental foods

**Source:** eCFR / USDA

**Why we should read it:** It explains that WIC eligibility is not a generic
nutrition score. Food category, form, package size, state authorization, and the
participant's prescribed package all matter.

**Affected use cases:** UC5 Identify product; UC6 Review product nutrition; UC7
Compare healthier alternatives; UC9 Choose healthier alternative; UC18 Review
benefit balances; UC19 Prepare checkout handoff.

**Possible Project 2 impact:** Define the vocabulary and hard boundary between
“nutritionally preferable,” “on the state APL,” “in this household's remaining
benefits,” and “accepted by the live transaction.”

**Priority:** MUST-READ

#### 6.2 NC APL and checkout recovery workflow

**Material:** NC WIC Authorized Product List and FFY 2025–2026 Vendor Manual

**Source:** NC Department of Health and Human Services

**Why we should read it:** These are the closest primary sources for WolfBite's
NC context. The manual describes APL downloads, balance checks, no overrides,
split tender, receipts, rejection causes, and the information a shopper can give
WIC staff when reporting a product problem.

**Affected use cases:** UC5, UC8, UC10–12, UC15, UC18–19.

**Possible Project 2 impact:** Use four evidence-backed synthetic causes—item not
in remaining benefits, inadequate quantity/balance, item not on the APL, or a
vendor with a stale APL—and recommend non-authoritative next steps rather than a
guaranteed diagnosis.

**Priority:** MUST-READ

#### 6.3 WIC EBT system boundaries

**Material:** WIC EBT Technical Implementation Guide and Operating Rules

**Source:** USDA Food and Nutrition Service

**Why we should read it:** It shows the parties and transaction/file interfaces
needed for actual authorization. This keeps the team from presenting a mock QR
handoff or cached app state as a retailer-approved transaction.

**Affected use cases:** UC18 Review benefit balances and UC19 Prepare checkout
handoff.

**Possible Project 2 impact:** Keep M0 offline/synthetic and put live reason-code,
balance, APL synchronization, and retailer integration outside scope unless a
qualified partner is available.

**Priority:** SHOULD-READ

#### 6.4 Desired WIC mobile-app features

**Material:** Weber et al. (2021), “Mobile App Features Desired by WIC
Participants”

**Source:** JMIR Formative Research

**Why we should read it:** The study used interviews and card sorting with 22
adult WIC caregivers. Balance checks and scanners were priorities, but
participants also emphasized ease, multilingual support, storage/performance,
and avoiding hassle.

**Affected use cases:** UC5, UC10, UC18–19.

**Possible Project 2 impact:** Measure whether recovery adds effort; favor a fast,
small, multilingual-ready path with no mandatory new account/profile fields.

**Priority:** MUST-READ

#### 6.5 Checkout identification difficulty and stigma

**Material:** Chauvenet et al. (2019), participant perspectives on the WIC
shopping experience

**Source:** Journal of Nutrition Education and Behavior / PubMed

**Why we should read it:** The four-state qualitative study reports that
identifying allowable items is a chief complaint and that checkout problems can
create stigma. The emotional/social cost is part of task success.

**Affected use cases:** UC5, UC8, UC18–19.

**Possible Project 2 impact:** Make the explanation private, neutral, short, and
non-blaming; do not require the shopper to debate the cashier or expose benefit
details publicly.

**Priority:** MUST-READ

#### 6.6 Newer evidence on WIC shopping

**Material:** Fiedler et al. (2025), WIC participant perspectives on the shopping
experience

**Source:** Journal of Nutrition Education and Behavior / PubMed

**Why we should read it:** It can confirm whether app/EBT improvements have
changed the burden since earlier studies and prevent the team from freezing an
outdated workflow model.

**Affected use cases:** UC5, UC8, UC18–19.

**Possible Project 2 impact:** Refine scenario frequencies and the validation
interview guide before investing in implementation.

**Priority:** SHOULD-READ

#### 6.7 Nutrition-data meaning and freshness

**Material:** FoodData Central API Guide and Data Documentation

**Source:** USDA Agricultural Research Service

**Why we should read it:** Branded records and nutrient coverage vary and change.
Missing is not the same as zero, and a manufacturer nutrition record is not WIC
purchase authorization.

**Affected use cases:** UC5–7, UC9, UC13.

**Possible Project 2 impact:** Preserve `unknown`, provenance, and source date;
remove misleading “healthier” badges when required fields are absent; do not use
nutrition data to explain an EBT rejection.

**Priority:** SHOULD-READ

### 7. Human Factors

| Human-Factor Topic | Source | Related UC(s) | Risk / Opportunity | Design Implication | Priority |
|---|---|---|---|---|---|
| Checkout stigma and time pressure | Chauvenet et al. (2019) | UC5, UC8, UC18–19 | A public failure can be embarrassing and a checkout line allows little time. More diagnostic detail can increase, not reduce, burden. | Default to a private, glanceable summary and one or two actions; use neutral language; permit dismissal and later review. | MUST-READ |
| Trust and calibrated uncertainty | FTC mobile-app guidance; NC Vendor Manual | UC5–7, UC18–19 | An app prediction can conflict with the register. False certainty damages trust and may cause confrontation. | Say “possible reason,” show source/freshness, explain that the register/benefit account decides, and offer a safe escalation route. | MUST-READ |
| Cognitive load and decision fatigue | W3C COGA Content Usable | UC5, UC10, UC12, UC18–19 | Multiple balances, categories, quantities, restrictions, and alternatives compete for attention. | Use progressive disclosure, plain words, one decision per view, persistent context, recognizable choices, and no memory-dependent steps. | SHOULD-READ |
| Error prevention, reversibility, and recovery | WCAG 2.2; W3C COGA | UC8, UC11, UC14–17, UC19 | Accidental quantity, basket, receipt, or handoff actions can change estimates and create confusion. | Confirm destructive actions, support undo/back, validate before commit, preserve user input after errors, and state how to correct the issue. | MUST-READ |
| Nonvisual and motor access | WCAG 2.2; WCAG2ICT | UC1–20; especially UC5, UC10, UC19 | Camera, small controls, color badges, and QR-only output can exclude users. | Provide text/manual UPC entry, semantics and focus order, large targets, non-color cues, scalable text, and a non-QR handoff alternative. | MUST-READ |
| Low connectivity, storage, and device performance | Weber et al. (2021) | UC4–5, UC10, UC18–19 | Slow or large apps and network-only lookup can fail at the point of need. | Keep the recovery flow lightweight; cache only necessary, dated data; expose offline/stale state; avoid making cloud OCR a prerequisite. | MUST-READ |
| Language and digital literacy | Weber et al. (2021); W3C COGA | UC1–2, UC5, UC18–19 | Technical EBT/APL language and English-only instructions can shift burden to the shopper. | Use tested plain-language labels, define unavoidable terms, design for localization, and validate with representative caregivers. | MUST-READ |
| Privacy and contextual consent | FTC app-security guidance; OCR.space privacy policy | UC10–11 | A “scan receipt” action may not make third-party full-image upload obvious. Receipts can contain more than UPCs. | Explain the processor and purpose before capture/upload, crop/redact or process locally, minimize retention, and allow a manual path. | MUST-READ |
| Fairness and nutrition-score bias | FoodData Central documentation; NIST AI RMF (conditional) | UC6–7, UC9, UC13 | Missing nutrient values currently behave like zero, which can systematically favor incomplete records and produce misleading “healthier” advice. | Use an explicit unknown state, require comparable data, show rationale/provenance, and test across food categories and incomplete records. | SHOULD-READ |
| Administrative and integration workload | USDA WIC EBT TIG; USDA modernization reporting | UC18–19; live Project 2 extension | Live APL/benefit/reason-code integration creates agency, vendor, processor, certification, support, and update work. | Keep M0 synthetic; document ownership and update frequency; require a partner and maintenance plan before live integration. | SHOULD-READ |

Notification overload and team-management controls do not currently deserve a
separate requirement: the 20 use cases contain no push-notification or workforce
management workflow. Reassess only if Project 2 adds reminders, messaging, or
staff dashboards.

### 8. Highest-Priority Reading List

| Rank | Source | Category | Why It Is High Priority | UC / Project 2 Connection |
|---:|---|---|---|---|
| 1 | NC WIC Vendor Manual, FFY 2025–2026 | State WIC workflow | It gives the closest authoritative description of checkout, no overrides, APL refresh, rejection causes, and escalation. | Defines the proposed mismatch scenarios and safe recovery actions around UC18–19. |
| 2 | NC WIC Authorized Product List page/data | State WIC data | It identifies the relevant product-authority source and its update context. | Prevents UC5 and Project 2 from confusing cached app recognition with current authorization. |
| 3 | 7 CFR §246.10 | Federal WIC regulation | It establishes what food-package eligibility means and who administers it. | Constrains UC5–7, UC9, UC18–19 claims and terminology. |
| 4 | Chauvenet et al. (2019) | Human factors/domain research | It documents allowable-item difficulty and checkout stigma with participants in four states. | Makes privacy, speed, and non-blaming language core Project 2 requirements. |
| 5 | Weber et al. (2021) | Domain/user research | It grounds scanner, balance, multilingual, performance, and ease priorities in caregiver research. | Shapes UC5, UC10, UC18–19 and recruitment/evaluation. |
| 6 | WCAG 2.2 | Accessibility | It turns inclusion into testable interface criteria. | Applies directly to scanner, explanation, and recovery controls. |
| 7 | FTC mobile-app marketing/privacy/security guidance | Consumer protection/privacy | WolfBite makes eligibility/nutrition claims and currently sends receipts to a processor. | Changes copy, disclosure, data minimization, vendor review, and security tests. |
| 8 | OCR.space API documentation and privacy policy | External service/privacy | This is the current receipt path, not a hypothetical dependency. | Determines whether UC10–11 should be retained, replaced with local OCR, or excluded. |
| 9 | OWASP MASVS | Mobile security | It supplies a focused verification baseline for the Flutter/Firebase data flow. | Covers authentication, storage, network, permissions, third parties, and privacy. |
| 10 | NIST SP 800-63B-4 | Authentication/session security | It exposes the gap between current six-character validation and modern account guidance. | Changes UC1–4/20 password, recovery, rate-limit, and logout requirements. |

### 9. MUST-READ Summary

**Total MUST-READ:** 10  
**Total SHOULD-READ:** 19  
**Total SKIM:** 5

These totals classify the 34-item long list in Section 2. License-table
priorities are component-level actions and are not added again.

#### 7 CFR §246.10 — Supplemental foods

**Organization:** U.S. Government / USDA Food and Nutrition Service

**Official Source / URL:**
https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.10

**Why it matters:** It is the federal foundation for WIC food packages and stops
the product from substituting a nutrition score or generic category match for a
participant-specific purchase decision.

**Affected Project 1a Use Cases:** UC5–7, UC9, UC18–19.

**Project 2 Decision It Could Change:** The feature's vocabulary, disclaimers,
scenario rules, and the decision not to claim authoritative eligibility or cause.

#### North Carolina WIC Authorized Product List

**Organization:** North Carolina Department of Health and Human Services

**Official Source / URL:**
https://www.ncdhhs.gov/divisions/child-and-family-well-being/community-nutrition-services-section/wic/vendors/nc-wic-authorized-product-list-apl

**Why it matters:** It is the relevant state product list, and APL presence is
only one part of a successful participant transaction.

**Affected Project 1a Use Cases:** UC5, UC10–11, UC18–19.

**Project 2 Decision It Could Change:** Whether a product status can be shown,
how freshness is communicated, and whether APL data can be redistributed.

#### NC WIC Vendor Manual, FFY 2025–2026

**Organization:** North Carolina Department of Health and Human Services

**Official Source / URL:**
https://www.ncdhhs.gov/ffy-2025-2026-vendor-manual-cover/download?attachment=

**Why it matters:** It provides direct evidence for checkout steps, rejection
causes, daily APL downloads, no overrides, split payment, and escalation.

**Affected Project 1a Use Cases:** UC5, UC8, UC11–12, UC15, UC18–19.

**Project 2 Decision It Could Change:** The complete mismatch taxonomy and the
actions shown after each synthetic scenario.

#### FTC mobile-app marketing, privacy, and security guidance

**Organization:** U.S. Federal Trade Commission

**Official Source / URL:**
https://www.ftc.gov/business-guidance/resources/marketing-your-mobile-app-get-it-right-start

**Why it matters:** It connects truthful capability/privacy claims with data
minimization, disclosure, secure handling, and third-party oversight.

**Affected Project 1a Use Cases:** All, especially UC5–7, UC10, UC18–19.

**Project 2 Decision It Could Change:** UI wording, substantiation, processor
notice/consent, retention, and whether cloud OCR remains in the product.

#### WCAG 2.2

**Organization:** World Wide Web Consortium (W3C)

**Official Source / URL:** https://www.w3.org/TR/WCAG22/

**Why it matters:** It is the strongest available testable accessibility baseline
for the interface, including errors, targets, focus, authentication, contrast,
and non-color communication.

**Affected Project 1a Use Cases:** UC1–20, especially UC1–2, UC5, UC10, UC14–19.

**Project 2 Decision It Could Change:** Interaction design, Flutter semantics,
manual fallbacks, and accessibility acceptance tests.

#### OWASP MASVS

**Organization:** OWASP Foundation

**Official Source / URL:** https://mas.owasp.org/MASVS/

**Why it matters:** It directly addresses the security/privacy surfaces of a
Flutter mobile app using accounts, cloud storage, device permissions, and an
external processor.

**Affected Project 1a Use Cases:** UC1–4, UC10–11, UC18–20.

**Project 2 Decision It Could Change:** Threat model, receipt-processing
architecture, Firebase rules tests, release checklist, and logging policy.

#### NIST SP 800-63B-4

**Organization:** National Institute of Standards and Technology

**Official Source / URL:** https://pages.nist.gov/800-63-4/sp800-63b.html

**Why it matters:** Modern authentication guidance is materially stronger than
WolfBite's current six-character client-side minimum and covers passwords,
rate-limiting, recovery, and sessions.

**Affected Project 1a Use Cases:** UC1–4 and UC20.

**Project 2 Decision It Could Change:** Whether account work is in scope and the
minimum acceptance criteria if Project 2 touches sign-in or saved recovery cases.

#### Mobile App Features Desired by WIC Participants

**Organization:** JMIR Formative Research

**Official Source / URL:** https://formative.jmir.org/2021/7/e30450/

**Why it matters:** It provides primary user research on desired features and
barriers including usability, multilingual support, device constraints, balance
checking, and scanning.

**Affected Project 1a Use Cases:** UC5, UC10, UC18–19.

**Project 2 Decision It Could Change:** Scope, recruitment, localization-ready
design, offline/performance requirements, and evaluation measures.

#### Participant perspectives on the WIC shopping experience

**Organization:** Journal of Nutrition Education and Behavior / PubMed

**Official Source / URL:** https://pubmed.ncbi.nlm.nih.gov/30502034/

**Why it matters:** It documents the real burden of identifying allowable items
and the stigma that can arise at checkout.

**Affected Project 1a Use Cases:** UC5, UC8, UC18–19.

**Project 2 Decision It Could Change:** Tone, privacy, time budget, number of
steps, and the rule against blaming the shopper, cashier, or store.

#### OCR.space API documentation and privacy policy

**Organization:** OCR.space

**Official Source / URL:** https://ocr.space/ocrapi and
https://ocr.space/privacypolicy

**Why it matters:** The current UC10 implementation uploads the complete receipt
to this service. Its behavior and terms affect privacy, consent, retention,
reliability, cost, and rate limits.

**Affected Project 1a Use Cases:** UC10–11.

**Project 2 Decision It Could Change:** Remove receipt OCR from scope, implement
verified on-device OCR, crop/minimize uploads, or complete a production-grade
processor and privacy review.

### 10. Project 2 Impact

| Area | Most Important Finding | Project 2 Recommendation |
|---|---|---|
| Legal / Regulatory | WIC rules and NC workflow constrain truthfulness, but the prototype is not itself the EBT authorization system. Privacy/accessibility duties depend on deployment facts; HIPAA/COPPA/Section 508 are not current blanket requirements. | Build a synthetic, non-authoritative explanation aid. Have the course/team label assumptions and obtain agency/legal review before live participant, retailer, or EBT integration. |
| Accessibility | Checkout recovery must work under time pressure without relying on color, camera, tiny targets, QR images, or memory. | Make WCAG 2.2 AA acceptance criteria part of M0; test screen reader, text scaling, focus, contrast, target size, errors, manual entry, and a text alternative to QR. |
| Security | The riskiest current flow is full-receipt upload; account/data access also depends on Firebase Rules and stronger auth/session behavior. | Keep receipt upload out of the Project 2 critical path; threat-model the actual data flow, deny-by-default/test rules, minimize logs/data, and adopt a small MASVS/NIST checklist. |
| Licensing | Direct package licenses are permissive, but notices must be retained; APL redistribution, the WIC logo, and full OCR service terms remain unclear. The lockfile is ignored. | Commit a resolved lockfile, ship generated notices, remove unused packages, replace/clear the logo, and obtain written data/service permission before external release. |
| Domain Knowledge | “App says eligible, register rejects” can arise from several layers: state APL, stale store copy, household benefit balance/quantity, item attributes, and the live transaction. | Base scenarios on the NC manual and federal rule; show source/freshness; never use nutrition data as the rejection explanation; put live authoritative diagnosis out of M0. |
| Human Factors | Identification difficulty, checkout stigma, language, device/network limits, and caregiver attention are core constraints, not polish. | Validate with representative WIC caregivers using a private, plain-language, multilingual-ready, one-minute recovery task; measure correct next action plus time and burden. |

Three concise takeaways:

1. Scope Project 2 as an evidence-based **likely-cause and next-step prototype**, not
   a live eligibility, benefit, or POS authority.
2. Treat **privacy, accessibility, and calibrated trust as acceptance criteria**:
   remove the full-receipt cloud dependency from the core path, meet WCAG 2.2 AA,
   and expose uncertainty/source freshness.
3. Resolve **release hygiene before adding integrations**: pin dependencies,
   preserve notices, clear the logo/APL rights, fix missing-nutrition semantics,
   and test Firebase authorization.

### 11. Sources

Only reviewed or verified sources used above are listed. A standard being listed
does not by itself make compliance legally mandatory.

1. **Source:** 7 CFR §246.10, Supplemental foods  
   **Organization:** eCFR / USDA  
   **URL:** https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.10  
   **Type:** Regulation / Domain Guidance  
   **Priority:** MUST-READ

2. **Source:** North Carolina WIC Authorized Product List  
   **Organization:** NC DHHS  
   **URL:** https://www.ncdhhs.gov/divisions/child-and-family-well-being/community-nutrition-services-section/wic/vendors/nc-wic-authorized-product-list-apl  
   **Type:** Domain Guidance / State Data  
   **Priority:** MUST-READ

3. **Source:** NC WIC Vendor Manual, FFY 2025–2026  
   **Organization:** NC DHHS  
   **URL:** https://www.ncdhhs.gov/ffy-2025-2026-vendor-manual-cover/download?attachment=  
   **Type:** Regulation / Domain Guidance  
   **Priority:** MUST-READ

4. **Source:** WIC EBT Technical Implementation Guide and Operating Rules  
   **Organization:** USDA Food and Nutrition Service  
   **URL:** https://www.fns.usda.gov/wic/ebt/technical-implementation-guide-operating-rules  
   **Type:** Standard / Domain Guidance  
   **Priority:** SHOULD-READ

5. **Source:** 7 CFR §246.26 and Protecting Participant Confidentiality  
   **Organization:** eCFR / USDA Food and Nutrition Service  
   **URL:** https://www.fns.usda.gov/wic/protecting-participant-confidentiality-within-cdc-screening-protocols  
   **Type:** Regulation / Privacy  
   **Priority:** SHOULD-READ

6. **Source:** Marketing Your Mobile App: Get It Right from the Start  
   **Organization:** U.S. Federal Trade Commission  
   **URL:** https://www.ftc.gov/business-guidance/resources/marketing-your-mobile-app-get-it-right-start  
   **Type:** Law / Consumer and Privacy Guidance  
   **Priority:** MUST-READ

7. **Source:** App Developers: Start with Security  
   **Organization:** U.S. Federal Trade Commission  
   **URL:** https://search.ftc.gov/business-guidance/resources/app-developers-start-security  
   **Type:** Security / Privacy Guidance  
   **Priority:** MUST-READ

8. **Source:** Privacy and Security Enforcement  
   **Organization:** U.S. Federal Trade Commission  
   **URL:** https://www.ftc.gov/news-events/topics/protecting-consumer-privacy-security/privacy-security-enforcement  
   **Type:** Law / Consumer Protection  
   **Priority:** SHOULD-READ

9. **Source:** N.C. Gen. Stat. §75-65  
   **Organization:** North Carolina General Assembly  
   **URL:** https://library.ncleg.gov/EnactedLegislation/Statutes/HTML/BySection/Chapter_75/GS_75-65.html  
   **Type:** Law / Privacy  
   **Priority:** SHOULD-READ

10. **Source:** Complying with COPPA: Frequently Asked Questions  
    **Organization:** U.S. Federal Trade Commission  
    **URL:** https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions  
    **Type:** Law / Privacy  
    **Priority:** SKIM

11. **Source:** HIPAA Covered Entities and Business Associates  
    **Organization:** HHS Office for Civil Rights  
    **URL:** https://www.hhs.gov/hipaa/for-professionals/covered-entities/index.html  
    **Type:** Law / Privacy  
    **Priority:** SKIM

12. **Source:** Guidance on Web Accessibility and the ADA  
    **Organization:** U.S. Department of Justice  
    **URL:** https://www.ada.gov/resources/web-guidance/  
    **Type:** Law / Accessibility Guidance  
    **Priority:** SHOULD-READ

13. **Source:** Section 508 Laws and Policies  
    **Organization:** U.S. General Services Administration  
    **URL:** https://www.section508.gov/manage/laws-and-policies/  
    **Type:** Law / Accessibility  
    **Priority:** SKIM

14. **Source:** Web Content Accessibility Guidelines 2.2  
    **Organization:** W3C  
    **URL:** https://www.w3.org/TR/WCAG22/  
    **Type:** Standard / Accessibility  
    **Priority:** MUST-READ

15. **Source:** Guidance on Applying WCAG 2 to Non-Web ICT (WCAG2ICT) 2.2  
    **Organization:** W3C  
    **URL:** https://www.w3.org/TR/wcag2ict-22/  
    **Type:** Standard / Accessibility  
    **Priority:** SHOULD-READ

16. **Source:** Mobile Application Security Verification Standard  
    **Organization:** OWASP Foundation  
    **URL:** https://mas.owasp.org/MASVS/  
    **Type:** Security Standard  
    **Priority:** MUST-READ

17. **Source:** Application Security Verification Standard  
    **Organization:** OWASP Foundation  
    **URL:** https://owasp.org/www-project-application-security-verification-standard/  
    **Type:** Security Standard  
    **Priority:** SHOULD-READ

18. **Source:** OWASP API Security Top 10  
    **Organization:** OWASP Foundation  
    **URL:** https://owasp.org/www-project-api-security/  
    **Type:** Security Guidance  
    **Priority:** SHOULD-READ

19. **Source:** NIST SP 800-63B-4, Authentication and Authenticator Management  
    **Organization:** NIST  
    **URL:** https://pages.nist.gov/800-63-4/sp800-63b.html  
    **Type:** Security Standard / Guidance  
    **Priority:** MUST-READ

20. **Source:** NIST Privacy Framework 1.0  
    **Organization:** NIST  
    **URL:** https://www.nist.gov/privacy-framework  
    **Type:** Privacy Standard / Guidance  
    **Priority:** SHOULD-READ

21. **Source:** NIST SP 800-218, Secure Software Development Framework 1.1  
    **Organization:** NIST  
    **URL:** https://csrc.nist.gov/pubs/sp/800/218/final  
    **Type:** Security Standard / Guidance  
    **Priority:** SHOULD-READ

22. **Source:** NIST SP 800-92, Guide to Computer Security Log Management  
    **Organization:** NIST  
    **URL:** https://csrc.nist.gov/pubs/sp/800/92/final  
    **Type:** Security Guidance  
    **Priority:** SHOULD-READ

23. **Source:** Contingency Planning / NIST SP 800-34  
    **Organization:** NIST  
    **URL:** https://csrc.nist.gov/Topics/Security-and-Privacy/security-programs-and-operations/contingency-planning  
    **Type:** Security Guidance  
    **Priority:** SHOULD-READ

24. **Source:** ISO/IEC 25010:2023, Product Quality Model  
    **Organization:** ISO/IEC  
    **URL:** https://www.iso.org/standard/78176.html  
    **Type:** Standard  
    **Priority:** SHOULD-READ

25. **Source:** ISO 9241-210:2019, Human-Centred Design  
    **Organization:** ISO  
    **URL:** https://www.iso.org/standard/77520.html  
    **Type:** Standard / Human Factors  
    **Priority:** SHOULD-READ

26. **Source:** ISO/IEC 27001:2022  
    **Organization:** ISO/IEC  
    **URL:** https://www.iso.org/standard/27001  
    **Type:** Security Standard  
    **Priority:** SKIM

27. **Source:** ISO/IEC/IEEE 29148:2018, Requirements Engineering  
    **Organization:** ISO/IEC/IEEE  
    **URL:** https://standards.ieee.org/standard/29148-2018.html  
    **Type:** Standard  
    **Priority:** SHOULD-READ

28. **Source:** Making Content Usable for People with Cognitive and Learning Disabilities  
    **Organization:** W3C  
    **URL:** https://www.w3.org/TR/coga-usable/  
    **Type:** Human Factors / Accessibility Guidance  
    **Priority:** SHOULD-READ

29. **Source:** Mobile App Features Desired by WIC Participants  
    **Organization:** JMIR Formative Research  
    **URL:** https://formative.jmir.org/2021/7/e30450/  
    **Type:** Domain Guidance / Human Factors  
    **Priority:** MUST-READ

30. **Source:** Participant perspectives on the WIC shopping experience  
    **Organization:** Journal of Nutrition Education and Behavior / PubMed  
    **URL:** https://pubmed.ncbi.nlm.nih.gov/30502034/  
    **Type:** Domain Guidance / Human Factors  
    **Priority:** MUST-READ

31. **Source:** Fiedler et al., participant perspectives on the WIC shopping experience  
    **Organization:** Journal of Nutrition Education and Behavior / PubMed  
    **URL:** https://pubmed.ncbi.nlm.nih.gov/40874893/  
    **Type:** Domain Guidance / Human Factors  
    **Priority:** SHOULD-READ

32. **Source:** OCR.space API documentation and privacy policy  
    **Organization:** OCR.space  
    **URL:** https://ocr.space/ocrapi and https://ocr.space/privacypolicy  
    **Type:** API Terms / Privacy  
    **Priority:** MUST-READ

33. **Source:** Firebase Security Rules and Authentication  
    **Organization:** Google Firebase  
    **URL:** https://firebase.google.com/docs/rules/rules-and-auth  
    **Type:** Security Guidance  
    **Priority:** SHOULD-READ

34. **Source:** Firebase Service Terms and Data Processing Terms  
    **Organization:** Google  
    **URL:** https://firebase.google.com/terms and https://firebase.google.com/terms/data-processing-terms  
    **Type:** Service Terms / Privacy  
    **Priority:** SHOULD-READ

35. **Source:** NIST AI Risk Management Framework 1.0  
    **Organization:** NIST  
    **URL:** https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10  
    **Type:** Standard / Risk Guidance  
    **Priority:** SKIM

36. **Source:** FoodData Central API Guide and Data Documentation  
    **Organization:** USDA Agricultural Research Service  
    **URL:** https://fdc.nal.usda.gov/api-guide/ and https://fdc.nal.usda.gov/data-documentation/  
    **Type:** Data/API License / Domain Guidance  
    **Priority:** SHOULD-READ

37. **Source:** OCR and package license pages (`provider`, `mobile_scanner`, `firebase_core`, `go_router`, `google_mlkit_text_recognition`, `http`, `image_picker`, `qr_flutter`, `excel`, `mockito`)  
    **Organization:** Package authors / pub.dev  
    **URL:** https://pub.dev/packages/provider/license, https://pub.dev/packages/mobile_scanner/license, https://pub.dev/packages/firebase_core/license, https://pub.dev/packages/go_router/versions/16.3.0/license, https://pub.dev/packages/google_mlkit_text_recognition/license, https://pub.dev/packages/http/license, https://pub.dev/packages/image_picker/license, https://pub.dev/packages/qr_flutter/license, https://pub.dev/packages/excel/license, and https://pub.dev/packages/mockito/license  
    **Type:** License  
    **Priority:** SHOULD-READ

38. **Source:** USDA WIC and Senior Farmers' Market Nutrition Programs Modernization Evaluation, 2024 Annual Report  
    **Organization:** USDA Food and Nutrition Service  
    **URL:** https://www.fns.usda.gov/research/wic/fmnp-modernization-evaluation/annual-report-2024  
    **Type:** Domain Guidance / Team Workload  
    **Priority:** SHOULD-READ

