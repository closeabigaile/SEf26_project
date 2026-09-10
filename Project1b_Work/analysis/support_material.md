# Support material

This is the working D3 register of regulations, standards, licenses, domain
guidance, and human-factors research that can change WolfBite's Project 2
design. It consolidates the Prompt 4 investigation with the sources and design
commitments already selected in `report/main.tex`. The complete Prompt 4 run is
preserved in
[`../model_outputs/codex/P04_support_material_2026-09-09.md`](../model_outputs/codex/P04_support_material_2026-09-09.md).

## Project 2 context and boundary

Project 2 currently targets an item-level explanation-and-recovery workflow for
a WIC shopper whose product appears eligible in an app but is rejected at
checkout. M0 will use fixed, synthetic mismatch scenarios and rule-based likely
causes and next steps. It will not use live WIC participant data, authorize a
purchase, change a benefit balance, connect to a retailer point of sale, or
claim to know the register's authoritative rejection reason.

`MUST-READ` means the team should review the source before freezing M0 scope or
acceptance criteria. `SHOULD-READ` means it should inform implementation or a
future production decision. `SKIM` identifies a deployment trigger to monitor;
it does not mean the source currently governs this student prototype.

## Prioritized support-material register

| Source | Type | Priority | Design area affected | Requirement or check created | URL |
|---|---|---|---|---|---|
| 7 CFR §246.10, especially §246.10(b) and (e)(12) | Federal WIC regulation | MUST-READ | Eligibility language and evidence; UC5–7, UC9, UC18–19 | Identify the jurisdiction, exact UPC/package, evidence source, and source date. Treat federal food/package criteria as general guidance, not a guarantee that an item is on the state APL, in the participant's remaining benefits, or accepted at checkout. | [eCFR](https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.10); [USDA FNS summary](https://www.fns.usda.gov/wic/food-packages/regulatory-requirements) |
| North Carolina WIC Authorized Product List and WIC Vendor Manual | State WIC data and domain guidance | MUST-READ | NC mismatch scenarios and recovery; UC5, UC8, UC10–12, UC15, UC18–19 | Use a dated synthetic APL fixture keyed by UPC and package details. Model evidence-backed causes such as an item absent from the remaining benefit, insufficient quantity, an item absent from the APL, or a vendor with a stale APL. Show only a likely cause and never offer an override. | [NC APL](https://www.ncdhhs.gov/divisions/child-and-family-well-being/community-nutrition-services-section/wic/vendors/nc-wic-authorized-product-list-apl); [Vendor Manual page](https://www.ncdhhs.gov/wic-vendor-manual-0) |
| WIC EBT Technical Implementation Guide and Operating Rules | Technical and domain guidance | SHOULD-READ | Integration boundary; UC18–19 | Keep agency, APL, household-benefit, and retailer-transaction evidence separate. M0 will use mock adapters and no card number, PIN, live purchase message, official balance, or balance mutation. | [USDA FNS](https://www.fns.usda.gov/wic/ebt/technical-implementation-guide-operating-rules) |
| FTC mobile-app marketing, privacy, and security guidance | Consumer protection, privacy, and security guidance | MUST-READ | Claims, collection, disclosure, and vendors; especially UC5–7, UC10, UC18–19 | Substantiate eligibility/nutrition claims; disclose what is collected and shared; minimize data; secure transmission and storage; review third parties; and use qualified wording such as “possible reason” rather than claiming an authoritative diagnosis. | [Marketing Your Mobile App](https://www.ftc.gov/business-guidance/resources/marketing-your-mobile-app-get-it-right-start); [App Developers: Start with Security](https://search.ftc.gov/business-guidance/resources/app-developers-start-security) |
| 7 CFR §246.26 and USDA WIC participant-confidentiality guidance | Federal WIC regulation and privacy guidance | SHOULD-READ | Future official participant/benefit data; UC1, UC4, UC18, UC20 | The current prototype does not hold official WIC records. If an agency later supplies personally identifying WIC information, require an authorized purpose, least-privilege access, disclosure limits, retention/deletion rules, and agency review before integration. | [eCFR](https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.26); [USDA explanation](https://www.fns.usda.gov/wic/protecting-participant-confidentiality-within-cdc-screening-protocols) |
| N.C. Gen. Stat. §75-65 | State breach-notification law | SHOULD-READ | Account, receipt, and incident handling; UC1–4, UC10, UC20 | Before a public release, inventory stored data, create an incident-response and notification decision process, and obtain legal review of whether the operator and exact data elements meet the statute's definitions. | [North Carolina General Assembly](https://library.ncleg.gov/EnactedLegislation/Statutes/HTML/BySection/Chapter_75/GS_75-65.html) |
| WCAG 2.2 Level AA | Accessibility standard and design target | MUST-READ | All user-facing UCs, especially UC1–2, UC5, UC10, UC14–19 | Convey approved/rejected/uncertain states with text and an icon rather than color alone; provide contrast, scalable text, semantics, logical focus, adequately sized or spaced targets, identified errors, correction suggestions, and consistent help. Test the recovery flow with assistive navigation and text scaling. | [W3C](https://www.w3.org/TR/WCAG22/) |
| WCAG2ICT 2.2 | Mobile accessibility guidance | SHOULD-READ | Translation of WCAG to Flutter/native screens; UC1–20 | Map WCAG requirements to native widgets, platform semantics, touch input, and non-web content. Use it as informative implementation guidance, not as a separate certification claim. | [W3C](https://www.w3.org/TR/wcag2ict-22/) |
| W3C Content Usable for People with Cognitive and Learning Disabilities | Cognitive-accessibility and usability guidance | SHOULD-READ | Explanation wording and recovery steps; UC1–2, UC5, UC10, UC12, UC18–19 | Use concrete language, one decision at a time, familiar controls, recognition instead of memory, prominent next actions, back/undo, and consistently placed human help. | [W3C](https://www.w3.org/TR/coga-usable/) |
| OWASP Mobile Application Security Verification Standard | Mobile security standard | MUST-READ | Accounts, device/cloud storage, permissions, network calls, and privacy; UC1–4, UC10–11, UC18–20 | Create a proportionate MASVS checklist for authentication, secure storage, network transport, platform permissions, third-party data flow, logging, and privacy. Keep receipt images, tokens, and benefit data out of logs. | [OWASP MASVS](https://mas.owasp.org/MASVS/) |
| OWASP API Security Top 10 and ASVS | API and application security guidance | SHOULD-READ | Firestore and OCR interfaces; UC4–5, UC10–11, UC18–20 | Threat-model document-level authorization, excessive data exposure, resource/rate-limit failure, input validation, unsafe trust in OCR results, error leakage, and incomplete API inventory. | [API Security](https://owasp.org/www-project-api-security/); [ASVS](https://owasp.org/www-project-application-security-verification-standard/) |
| NIST SP 800-63B-4 | Authentication and session guidance | MUST-READ | Account lifecycle; UC1–4, UC20 | Do not retain the current six-character password rule as the design target. Support long passwords and password-manager paste, screen compromised passwords, rate-limit attempts, protect recovery, and make sign-out terminate the intended session. | [NIST](https://pages.nist.gov/800-63-4/sp800-63b.html) |
| NIST Privacy Framework 1.0 | Privacy engineering guidance | SHOULD-READ | Account, receipt, telemetry, retention, and deletion; UC1, UC4, UC10–11, UC20 | Maintain a data map containing each field, purpose, processor, retention period, access rule, deletion behavior, and user notice. Do not collect data merely because the inherited implementation supports it. | [NIST](https://www.nist.gov/privacy-framework) |
| NIST Secure Software Development Framework 1.1 | Secure-development guidance | SHOULD-READ | Dependencies, source, build, review, and release | Pin dependencies, review changes, scan for secrets and known vulnerabilities, protect build artifacts, document releases, and define vulnerability triage. | [NIST SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final) |
| Firebase Security Rules, service terms, and data-processing terms | Cloud security and service terms | SHOULD-READ | Authentication and Firestore data; UC1–5, UC8, UC11–12, UC14–20 | Treat Security Rules—not public client configuration—as the access boundary. Deny by default, authorize user records by authenticated UID, validate field shape/range, govern APL writes separately, and test rules in the emulator. Document retention, backup, processor, and configuration responsibilities. | [Rules and Authentication](https://firebase.google.com/docs/rules/rules-and-auth); [Terms](https://firebase.google.com/terms); [Data Processing Terms](https://firebase.google.com/terms/data-processing-terms) |
| OCR.space API documentation and privacy policy | External API and privacy terms | MUST-READ | Receipt scanning; UC10–11 | The inherited UC10 path uploads the complete receipt image. Keep OCR outside the core Project 2 recovery path. If retained, explain the processor and purpose before upload, minimize/crop the image or use verified on-device processing, handle limits/errors, define retention, and provide manual UPC entry. | [API](https://ocr.space/ocrapi); [Privacy Policy](https://ocr.space/privacypolicy) |
| Inherited WolfBite MIT License | Application license | MUST-READ | Modification and redistribution of all inherited code | Preserve the inherited copyright and MIT permission/warranty notice in copies or substantial portions. Do not describe the prototype as warranted or officially endorsed. | [`Project3/LICENSE.md`](../../Project3/LICENSE.md); [upstream license](https://github.com/SuyeshJadhav/CSC510_G19/blob/main/Project2/LICENSE.md) |
| Direct and transitive Flutter package licenses | Dependency licenses | SHOULD-READ | Builds and redistributed app artifacts | Preserve the generated MIT, BSD, Apache, and other required notices. Record exact resolved versions and licenses, check new dependency compatibility, remove unused packages, and reject dependencies whose obligations cannot be met. No copyleft direct dependency was identified in the reviewed resolution. | [`Project3/pubspec.yaml`](../../Project3/pubspec.yaml); [provider](https://pub.dev/packages/provider/license); [mobile_scanner](https://pub.dev/packages/mobile_scanner/license); [firebase_core](https://pub.dev/packages/firebase_core/license) |
| USDA FoodData Central API Guide and Data Documentation | Data/API license and domain guidance | SHOULD-READ | Nutrition lookup and “healthier” comparisons; UC5–7, UC9, UC13 | Treat FoodData Central data as public domain/CC0 with attribution requested, protect API keys, retain provenance and source date, and preserve missing nutrients as unknown. Never convert missing data to zero or treat nutrition data as WIC purchase authorization. | [API Guide](https://fdc.nal.usda.gov/api-guide/); [Data Documentation](https://fdc.nal.usda.gov/data-documentation/) |
| Weber et al. (2021), “Mobile App Features Desired by WIC Participants” | WIC user research and human factors | MUST-READ | Feature priority, language, performance, and burden; UC5, UC10, UC18–19 | Keep the recovery path simple, lightweight, and localization-ready. Do not require extra profile data, persistent connectivity, or cloud OCR to complete the core task. Validate with WIC caregivers rather than only classmates or developers. | [JMIR Formative Research](https://formative.jmir.org/2021/7/e30450/) |
| Chauvenet et al. (2019), participant perspectives on WIC shopping | WIC user research and human factors | MUST-READ | Allowable-item identification, checkout stigma, and time pressure; UC5, UC8, UC18–19 | Make the explanation private, short, neutral, and non-blaming. Provide one or two safe next actions without requiring the shopper to debate the cashier or expose benefit details publicly. | [PubMed](https://pubmed.ncbi.nlm.nih.gov/30502034/) |
| Fiedler et al. (2025/2026), WIC participant perspectives | Current WIC user research | SHOULD-READ | Validation of current shopping barriers; UC5, UC8, UC18–19 | Use the newer participant evidence to refine scenario frequency, terminology, interview questions, and whether earlier reports of burden still match current WIC app/EBT use. | [PubMed](https://pubmed.ncbi.nlm.nih.gov/40874893/) |
| ISO 9241-210:2019 | Human-centered design standard | SHOULD-READ | M0 research and iteration; UC5, UC8, UC12, UC18–19 | Test the workflow in its checkout context with representative users. Measure correct next action, time, facilitator help, comprehension, and burden—not screen preference alone—and iterate from the results. | [ISO](https://www.iso.org/standard/77520.html) |
| ISO/IEC 25010:2023 | Software product-quality model | SHOULD-READ | Cross-cutting quality and M0 acceptance criteria | Trace tests to functional suitability, reliability, interaction capability, security, compatibility, maintainability, flexibility, and safety from misleading output. | [ISO](https://www.iso.org/standard/78176.html) |
| ISO/IEC/IEEE 29148:2018 | Requirements-engineering standard | SHOULD-READ | Project 2 requirements and traceability | Specify the mismatch trigger, scenario inputs, source freshness, uncertainty language, outputs, recovery actions, manual fallback, privacy constraints, external-system boundaries, and measurable acceptance tests. | [IEEE](https://standards.ieee.org/standard/29148-2018.html) |

## Consolidated Project 2 checks

Before M0 implementation or evaluation, the team should be able to check each
of these statements against a requirement, test, fixture, or interface artifact:

- [ ] Every scenario distinguishes federal food criteria, current NC APL
      evidence, household benefit evidence, and the retailer's actual result.
- [ ] Every status identifies the exact item/package, jurisdiction, evidence
      source, and fixture/source date.
- [ ] Explanations say “likely” or “possible” when WolfBite lacks an
      authoritative reason and never offer a register override.
- [ ] M0 uses synthetic data and mock adapters; no card number, PIN, live WIC
      record, official balance, or POS message is collected or changed.
- [ ] The flow provides one or two concise, non-blaming next actions plus
      consistently placed agency help.
- [ ] Approval, rejection, and uncertainty never rely on color alone; the flow
      passes contrast, text-scaling, focus/semantics, target-size, and error-help
      checks based on WCAG 2.2 Level AA.
- [ ] A shopper can enter a UPC and read/share the result without depending on
      a camera, receipt upload, or QR image.
- [ ] Receipt OCR is outside the core M0 path. Any retained upload has prior
      disclosure, data minimization, service review, error handling, and a
      documented retention/deletion decision.
- [ ] Firebase rules deny by default, isolate each user's records, validate
      expected fields, and are covered by emulator tests.
- [ ] Authentication requirements replace the six-character local minimum with
      a documented policy informed by NIST SP 800-63B-4.
- [ ] Missing nutrition fields remain unknown rather than becoming zero, and
      nutrition comparisons never serve as evidence for WIC eligibility or a
      checkout rejection cause.
- [ ] The exact dependency resolution and notices are reproducible, inherited
      MIT terms are retained, and every distributed asset/data source has
      recorded provenance and permission.
- [ ] M0 reports the preregistered target honestly: at least 80% task success
      and at least a 20-percentage-point improvement over baseline within 60
      seconds are targets to measure, not achieved results.

## Applicability boundaries

| Material | Priority | Current assessment | Trigger for reassessment | Source |
|---|---|---|---|---|
| ADA Titles II/III | SHOULD-READ | Potentially relevant to a covered public-agency or public-accommodation deployment; the student prototype alone does not establish applicability. WCAG 2.2 AA remains the engineering target regardless. | Deployment by a state/local WIC agency or another covered service. | [U.S. DOJ accessibility guidance](https://www.ada.gov/resources/web-guidance/) |
| Section 508 | SKIM | Not currently applicable. | Federal operation, use, or procurement. | [Section508.gov](https://www.section508.gov/manage/laws-and-policies/) |
| COPPA | SKIM | Not currently indicated because the documented actor is an adult shopper/caregiver and WolfBite does not intentionally collect data directly from children under 13. | Child-directed design, child accounts, or actual knowledge of under-13 data collection. | [FTC COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions) |
| HIPAA | SKIM | Not currently applicable merely because WolfBite displays nutrition or WIC information. | Operation for a HIPAA-covered entity or business associate using protected health information. | [HHS covered-entity guidance](https://www.hhs.gov/hipaa/for-professionals/covered-entities/index.html) |
| PCI DSS | SKIM | Not currently applicable because shopper-paid estimates and QR handoff do not process cardholder data. | Adding real in-app card acceptance, storage, processing, or transmission. | [PCI Security Standards Council](https://www.pcisecuritystandards.org/standards/pci-dss/) |
| ISO/IEC 27001:2022 | SKIM | Disproportionate for the course prototype. | Production operator, agency procurement, or contract requiring an information-security management system. | [ISO](https://www.iso.org/standard/27001) |
| NIST AI RMF 1.0 | SKIM | The selected feature is deterministic and rule-based, not predictive AI. | Adding ML-generated eligibility, nutrition, or rejection-cause decisions. | [NIST](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10) |

No documented use case currently creates a meaningful labor-law, tax,
food-safety-handling, GLBA, or workforce-management requirement.

## Unresolved items before public distribution

1. **NC APL rights and refresh:** public availability does not establish a
   redistribution/modification license. Obtain NCDHHS guidance before bundling
   or republishing the APL, and define update ownership and freshness labeling.
2. **WIC logo asset:** the provenance and permission for
   `Project3/assets/images/wic-logo.png` are unverified. Replace it with an
   original neutral asset or document permission; avoid implying USDA/NCDHHS
   endorsement.
3. **OCR.space terms:** the API documentation and privacy policy were reviewed,
   but the full service-license/DPA fit for a production receipt workflow remains
   unresolved. The safest M0 decision is to exclude full-receipt cloud upload.
4. **Dependency reproducibility:** `Project3/pubspec.lock` is ignored even
   though package compatibility and licenses depend on resolved versions. Commit
   an appropriate application lockfile, regenerate notices, and remove unused
   dependencies before release.
5. **Deployment-specific legal review:** confidentiality, breach notification,
   ADA/Section 508, COPPA, and HIPAA conclusions must be revisited if the
   operator, users, data, or integrations change.
