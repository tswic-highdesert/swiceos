# Subcontractor Agreement Rubric

**Version 1.0.0** · Single source of truth · Human-editable, machine-walkable.
Walk **every** provision. Assign 🟢/🟡/🔴 or ⚪ Not addressed. Cite a verbatim quote + page + section for each.
Flags: `never_auto_green` (cannot be Green/Not-addressed without HUMAN-VERIFY) · `state_law_dependent` (feeds/uses Step 2) · `exec` = auto-escalation bucket.

> "The Company" = the party you are protecting (the sub / trade contractor); see `config.md`. "Home state" = the Company's preferred venue from `config.md`.
> Redline language below is the Company's fallback negotiating position. Lines marked **[proven]** are battle-tested field language; **[standard]** are common standard positions; **[draft]** needs confirmation from the rubric owner. Swap in your own vetted positions via `config.md`.

---

## A. Payment & Cash Flow

### Payment Contingency (pay-if-paid vs pay-when-paid) `payment_contingency`
`never_auto_green` · `state_law_dependent` · exec: Financial
- 🟢 Payment to the Company is **not** contingent on the owner paying the GC.
- 🟡 **Pay-when-paid** (timing only — payment within a reasonable time). The Company's preferred fallback if contingency is unavoidable.
- 🔴 **Pay-if-paid**: owner payment is a "condition precedent," "absolute condition," or the sub "relies solely on the credit of Owner / assumes the risk of non-payment by Owner."
- **Detection cues:** "condition precedent", "absolute condition precedent", "only out of … payments received", "relies solely and exclusively on the credit of Project Owner", "assumed the risk of non-payment".
- **Carve-out check:** a "Net 30" that runs "from Owner's payment to Contractor" is pay-if-paid in disguise.
- **Redline [standard]:** "Payment to Trade Contractor shall not be contingent upon payment by Owner." Fallback [proven-practice]: convert to pay-when-paid — payment within a reasonable time, not as a condition precedent — and confirm enforceability for the governing-law state (Step 2).

### Payment Mechanics / Days-to-Pay `payment_mechanics`
exec: Financial (if >60 effective)
- 🟢 Net 30-45 measured from invoice/approval.
- 🟡 Net 60 from invoice/approval.
- 🔴 >60 effective days, **or** the clock runs from "Contractor's receipt of payment from Owner" (stacks on top of the owner's cycle).
- **Detection cues:** "within ___ days of", "after Contractor's receipt of payment from Owner", application-for-payment due date, "days after".
- **Redline [draft]:** "Payment shall be due within thirty (30) days of Trade Contractor's application for payment, measured independently of Owner's payment to Contractor."

### Billing / Conditions to Payment `billing_conditions`
exec: Financial
- 🟢 Standard application for payment.
- 🟡 Requires submittals the Company does not customarily provide: **statutory sworn statements**, **supplier / Sub-trade contract amounts**, statutory **unconditional** lien waivers as a condition of each payment.
- 🔴 Payment withheld in full for failure to provide non-standard documentation, or documentation requirements that exceed the scope.
- **Detection cues:** "sworn statement", "unconditional lien waiver", "subcontract amounts", "supplier amounts", "any other documents … requested by".
- **Redline [draft]:** "Conditions to payment shall be limited to a standard application for payment and conditional lien waivers in the statutory form for the Project state; Trade Contractor shall not be required to disclose subcontractor/supplier contract amounts or provide unconditional waivers in advance of payment." (See Lien-Waiver Mechanics.)

### Deposit / Mobilization `deposit`
exec: Financial
- 🟢 Deposit or mobilization billing accepted; stored materials billable.
- 🟡 Partial procurement funding only.
- 🔴 No deposit **and** no mobilization billing (severe when the Company funds long-lead materials/equipment — see `config.md`).
- **Detection cues:** "no deposit", "mobilization", "down payment", "procurement".
- **Redline [draft]:** "Trade Contractor shall be entitled to bill an initial mobilization/procurement payment for long-lead materials and equipment."

### Retention `retention`
`state_law_dependent` · exec: Financial
- 🟢 ≤5% released at substantial completion of **the Company's scope**.
- 🟢 **10% released at substantial completion** where that is the state requirement / contract norm — acceptable, **not** a Yellow.
- 🔴 **>10%** (no known state requires more), **or** retention held to **project/owner final acceptance** instead of the Company's scope completion.
- **Status quo — not a finding:** retention applied to **stored materials** and **change-order** billings is normal AIA practice; do not flag it.
- **Detection cues:** "retainage", "retention", "% withheld", "released upon … final completion of the overall project", "released to Contractor in the Prime Contract".
- **Redline [standard]:** "Retainage shall not exceed [state cap]% and shall be released upon substantial completion of Trade Contractor's scope of Work, independent of overall Project completion or Owner's release to Contractor."

### Stored Materials `stored_materials`
exec: Financial
- 🟢 Billable with invoices/evidence.
- 🟡 Limited or conditioned (off-site bonded storage, separate insurance, title transfer, separate retention) — rate the conditions, not just "allowed."
- 🔴 No stored-materials billing allowed.
- **Detection cues:** "stored materials", "offsite stored materials", "materials stored".

### Pay App Releases / Lien-Waiver Mechanics `lien_waiver_mechanics`
`never_auto_green` · exec: Financial
- 🟢 **Conditional** waivers limited to the amount actually received.
- 🔴 **Unconditional** waiver signed before payment clears; waiver "through date X / whether or not included in this payment"; waiver releasing retention or pending change orders; acceptance of final payment waiving all claims except those made in writing beforehand.
- **Rule:** progress waivers must be conditional; only the **final** waiver may be unconditional, and only after the final check clears.
- **Detection cues:** "unconditional", "lien waiver", "waiver of claims", "acceptance of final payment … waiver", "through the date of".
- **Redline [draft]:** "All progress lien waivers shall be conditional upon actual receipt of payment. No waiver shall release retention, pending change orders, or claims submitted in writing."

### Lien & Bond Rights Waiver `lien_bond_rights`
`never_auto_green` · exec: Legal
- 🟢 No waiver of statutory lien/bond rights.
- 🔴 Prospective "no-lien" clause, or waiver of payment-bond / Miller Act / Little Miller Act claim rights.
- **Detection cues:** "waives any lien", "no lien", "waiver of bond", "Miller Act".
- **Redline [draft]:** "Trade Contractor does not waive its statutory mechanic's lien or payment-bond claim rights."

### Cross-Project Setoff / Withholding `cross_project_setoff`
exec: Financial
- 🟢 No setoff, or setoff limited to this project with notice + documentation.
- 🟡 Same-project setoff, capped, with notice.
- 🔴 Setoff against "any other agreement / any other project," or withholding on a mere "reasonable belief" of breach.
- **Detection cues:** "set off", "offset", "any other agreement", "any other project", "recoup", "reasonable belief … likely to breach".
- **Redline [draft]:** "Setoff shall be limited to amounts actually owed on this Project, supported by documentation, after written notice and opportunity to cure."

### Final Payment Conditions `final_payment_conditions`
exec: Financial
- 🟢 Final payment due on completion of the Company's scope + standard closeout.
- 🔴 Final payment / retention release gated on consent of surety, lower-tier vendor waivers, or unrelated owner closeout; **final-invoice-or-waived** deadlines.
- **Detection cues:** "consent of surety", "final invoice … deemed waived", "no further payments shall be owed", "closeout", "as-built", "O&M".
- **Redline [proven]:** "Failure to timely submit a final invoice shall not constitute waiver of amounts otherwise earned and due, provided Trade Contractor submits the invoice within a reasonable time."

### Backcharges `backcharges`
exec: Financial
- 🟢 Notice + documentation + opportunity to cure required.
- 🟡 Limited rights.
- 🔴 Customer may backcharge at its discretion.
- **Detection cues:** "backcharge", "back charge", "charge all costs", "deduct from the Contract Sum".
- **Redline [proven]:** "No backcharge shall be assessed unless Contractor provides written notice describing the issue, supporting documentation of actual costs incurred, and a reasonable opportunity for Trade Contractor to cure."

### Certified Payroll `certified_payroll`
- 🟢 Required by law only (e.g., prevailing-wage/Davis-Bacon project).
- 🟡 Customer-requested beyond legal requirement.
- 🔴 Required without legal obligation.
- **Detection cues:** "certified payroll", "prevailing wage", "Davis-Bacon".

### Software / Platform Costs `software_platforms`
exec: Financial
- 🟢 Customer pays platform costs.
- 🟡 Shared cost, **or** mandatory platform use with the **cost allocation silent** (presume the Company funds it → Yellow, flag to clarify).
- 🔴 The Company expressly funds the platform / per-application portal fees (Textura, GCPay, Procore, PlanGrid).
- **Detection cues:** "Procore", "Textura", "GCPay", "PlanGrid", "project software", "subscription", "shall utilize project software as required".

### Material Escalation `material_escalation`
exec: Financial
- 🟢 Escalation / tariff clause included.
- 🟡 Capped or threshold-shared escalation (e.g., shared above 3-5%).
- 🔴 No protection on long-lead fixed-price scope (Red, not a soft flag, in the current tariff climate).
- **Detection cues:** "escalation", "tariff", "surcharge", "price increase", "fixed price", "lump sum".
- **Redline [standard]:** "Trade Contractor reserves the right to equitable adjustment for tariffs, freight increases, manufacturer surcharges, and material escalation."

### Freight / Storage `freight_storage`
exec: Financial
- 🟢 Reimbursable, or freight in scope **with** an escalation/adjustment mechanism.
- 🟡 Freight bundled in a fixed/lump-sum price with no escalation or demurrage relief.
- 🔴 The Company bears **freight cost-increase / demurrage / extended-storage** risk with no recovery, especially on long-lead scope.
- **Calibration note:** freight simply being *included* in a sub's lump-sum scope is industry-normal — do **not** Red it on that basis. The Red is unrecoverable freight *cost-increase / demurrage* risk. Pairs with Material Escalation.
- **Detection cues:** "freight", "storage", "shipping", "demurrage", "all … freight … included".

---

## B. Schedule & Delay

### Schedule Changes `schedule_changes`
exec: Schedule
- 🟢 Compensable for changes the Company didn't cause.
- 🟡 Limited schedule revisions.
- 🔴 Unilateral revision without compensation; **float belongs to the project/GC**; **schedule incorporated "as updated from time to time" with no dated baseline attached**.
- **Detection cues:** "may change, revise or modify … without adjustment", "float", "as updated from time to time", "priority".
- **Redline [standard]:** "Any acceleration, resequencing, overtime, remobilization, or manpower increases shall entitle Trade Contractor to an equitable adjustment in Contract Sum and Contract Time."

### Acceleration `acceleration`
exec: Schedule
- 🟢 Paid acceleration.
- 🟡 Negotiated acceleration.
- 🔴 Mandatory overtime/weekends/added manpower with **no increase to the Contract Sum**.
- **Detection cues:** "work overtime and weekends", "additional manpower without increase", "time is of the essence", "catch up".
- **Redline [proven]:** "If acceleration, overtime, additional shifts, weekend work, resequencing, or additional manpower are required due to causes not solely attributable to Trade Contractor, Trade Contractor shall be entitled to an equitable adjustment in the Contract Sum and Schedule."

### Delays / No-Damages-for-Delay `delays`
exec: Schedule
- 🟢 Compensable delays.
- 🟡 Time extension only.
- 🔴 No-damages-for-delay; "sole and exclusive remedy = extension of time"; relief only for "active interference" (illusory); no comp for concurrent delay.
- **Detection cues:** "no damages for delay", "sole and exclusive remedy", "extension of time as its only remedy", "no increase … for concurrent delays".
- **Redline [proven]:** "Trade Contractor shall be entitled to a reasonable extension of time and equitable adjustment for delays caused in whole or in part by Contractor, Owner, architect, engineer, or other contractors, notwithstanding concurrent delays."

### Remobilization `remobilization`
exec: Schedule
- 🟢 Compensable.
- 🟡 Undefined.
- 🔴 No compensation for remobilization.
- **Detection cues:** "remobilization", "demobilization", "stand-by", "suspension of work".
- **Redline [standard]:** "Trade Contractor shall be entitled to compensation for delays, disruptions, remobilizations, and extended overhead caused by others."

### Notice & Claim Conditions Precedent `notice_claim`
exec: Schedule · Legal
- 🟢 ≥30 days or "reasonable notice."
- 🟡 14-21 days.
- 🔴 Notice window **<7 days** (e.g., 14-day claim, 24-hour or 48-hour notice) **or** "failure to notify = waiver / time-barred."
- **This is the single most common way valid claims die. Always extract every notice/claim deadline into the Deadline Register, with page cites.**
- **Detection cues:** "within ___ days/hours", "written notice", "condition precedent", "deemed a waiver", "shall be waived", "time-barred", "or barred".
- **Redline [draft]:** "Notice periods for claims shall be no less than fourteen (14) days, and failure to strictly comply shall not waive an otherwise valid claim where Contractor has actual knowledge and is not prejudiced."

### Liquidated Damages `liquidated_damages`
`never_auto_green` · exec: Schedule
- 🟢 None.
- 🟡 Capped and negotiated.
- 🔴 Unlimited or flow-down; no mutual cap; whole-project LDs assessed on the Company for others' lateness; concurrent-delay defense waived.
- **Detection cues:** "liquidated damages", "$___ per day", "pass-through", "reimburse Contractor such amount".
- **Redline [proven]:** "Trade Contractor's liability for liquidated damages shall be limited to liquidated damages actually assessed against Contractor by Owner and solely to the extent caused by Trade Contractor's delay; in no event shall it exceed the remaining unpaid Contract Sum."

### Force Majeure / Excusable Delay `force_majeure`
exec: Schedule
- 🟢 Time + money relief for causes outside the Company's control.
- 🟡 Time-only relief.
- 🔴 No relief, or relief only if the Prime grants it (asymmetric — GC gets relief the sub doesn't).
- **Detection cues:** "force majeure", "unavoidable casualties", "pandemic", "weather", "if the Prime Contract contains provisions granting relief".

### Substantial Completion `substantial_completion`
exec: Schedule · Operational
- 🟢 Defined by completion of the Company's scope.
- 🟡 Partially defined.
- 🔴 Tied to owner acceptance / owner's billing / project completion (gates warranty start, retention release, and LD cutoff at once — auto-escalate).
- **Detection cues:** "substantial completion … as defined in the Prime Contract", "beneficial occupancy", "Owner acceptance".
- **Redline [standard]:** "Substantial completion shall occur when Trade Contractor has completed its contractual scope of work, excluding minor punch list items."

---

## C. Scope & Execution

> **Industry-specific section.** These rows are written for specialty / critical-environment trade work (clean room, data center, healthcare, controlled-temp/humidity, or any scope delivering a measurable environmental/performance result). If your work is ordinary construction with no such result, several of these soften to Yellow/informational — set your specialty scope in `config.md` and adapt these rows in your own copy.

### Scope Definition `scope_definition`
exec: Operational
- 🟢 Inclusion list with explicit exclusions.
- 🟡 Mixed.
- 🔴 Result-based / open-ended: "complete and operational," "reasonably inferable," "whether or not shown or specified."
- **Detection cues:** "complete and operational", "reasonably inferable", "whether or not shown", "all work necessary".
- **Redline [draft]:** "Scope is limited to the work expressly listed in Exhibit A; work not shown is excluded unless added by Change Order."

### Prime Contract Flow Down / Incorporation `flow_down`
`never_auto_green` · exec: Legal
- 🟢 Scope-specific only.
- 🟡 Partial incorporation.
- 🔴 Entire prime incorporated; liability "to the same extent Contractor is liable to Owner" (conduit clause); flow-down of the prime's notice/dispute deadlines, LDs, or schedule; "Prime Contract shall govern."
- **Detection cues:** "incorporated by reference", "as if fully set forth", "to the same extent that Contractor is liable to Owner", "Prime Contract shall govern", "bound … to the same extent".
- **Redline [proven]:** "Trade Contractor shall only be bound by provisions of the Prime Contract that directly relate to the scope, timing, quality, and manner of Trade Contractor's Work and that have been provided to and reviewed by Trade Contractor."

### Order of Precedence `order_of_precedence`
exec: Legal
- 🟢 Subcontract controls, or conflicts resolved in the Company's favor.
- 🔴 "Most stringent / greater obligation governs," or the Prime/General Conditions rank above the subcontract — silently overrides favorable body terms.
- **Detection cues:** "most stringent", "greater obligation", "shall govern", "in the event of conflict … Prime Contract".
- **Note:** when present, all body ratings are **provisional** until precedence is resolved.

### Future Prime Contract Changes / Silence-Acceptance `prime_changes`
exec: Legal
- 🔴 "Silence within [5] business days is deemed acceptance" of a later-executed or revised Prime Contract.
- **Detection cues:** "five business days", "silence … deemed acceptance", "upon finalization … of the Prime Contract".
- **Redline [proven]:** "Material changes affecting Trade Contractor's scope, cost, schedule, insurance, warranty, indemnity, or risk allocation shall require written acceptance by Trade Contractor."

### Site Readiness / Environmental Preconditions `site_readiness`
exec: Operational
- 🟢 Customer responsible; "ready-for-work" defined as a condition precedent (for critical-environment work: enclosure dried-in, temp/RH band, dust/FOD control, conditioned power, HVAC running, overhead trades complete).
- 🟡 Shared responsibility.
- 🔴 The Company assumes all site-readiness risk, or "ready" is undefined for an environment-sensitive scope. ⚪ Not addressed here = Red where the Company's work depends on controlled site conditions.
- **Detection cues:** "site readiness", "ready for work", "preliminary investigations … to the same extent", "conditions of the site".
- **Redline [draft]:** "Trade Contractor's start of environment-sensitive finishes is conditioned on the space being dried-in, environmentally conditioned (temperature/humidity within spec), dust/FOD-controlled, with overhead trades complete; delays in achieving these conditions entitle Trade Contractor to equitable adjustment."

### Coordination / BIM / Clash Responsibility `coordination_bim`
exec: Operational
- 🟢 Coordination duties matched with authority and clash-cost allocation.
- 🔴 Coordination / clash-resolution duty assigned without authority over other trades or a cost allocation.
- **Detection cues:** "coordinate", "coordination drawings", "BIM", "clash", "responsible for fit", "Exhibit A.2".

### Commissioning / Certification / Validation `commissioning`
exec: Operational
- 🟢 Cert is a shared milestone with conditions the Company controls; retest cost falls on the party that caused the failure; a cleared, conditioned space is guaranteed for the test window.
- 🔴 The Company must deliver a "certified" result without controlling the test conditions, or eats retests it didn't cause.
- **Detection cues:** "certified", "ISO 14644", "Class ___", "validation", "performance test", "at-rest / operational testing", "recovery rate".
- **Redline [draft]:** "Certification testing is conditioned on a cleared, environmentally-conditioned space; retest costs arising from causes outside Trade Contractor's control shall be borne by the responsible party."

### Performance Guarantee / Fitness-for-Purpose `performance_guarantee`
`never_auto_green` · exec: Operational · Legal
- 🟢 Workmanship-only standard (industry standard of care).
- 🔴 Guarantees a measurable classification/performance **result** the owner's own operations can defeat (largely **uninsurable** — often the biggest single technical liability for specialty scope).
- **Detection cues:** "achieve", "shall meet/maintain ISO", "fit for owner's intended purpose", "performance guarantee", "guarantee that".
- **Redline [draft]:** "Trade Contractor warrants workmanship and materials to the professional standard of care; Trade Contractor does not guarantee performance results dependent on Owner's operation, maintenance, or other trades."

### Design Delegation / Standard of Care `design_delegation`
`never_auto_green` · exec: Legal · Operational
- 🟢 No delegated design, or design carries a professional-negligence standard backed by matching E&O.
- 🔴 Design responsibility shifted without a negligence standard or matching insurance ("delegated design," "design/build" boxes — see Exhibit A.1).
- **Detection cues:** "delegated design", "design/build", "Exhibit A.1", "professional standard of care", "design responsibility".

### Protection of Work / FOD & Final-Clean Backcharges `protection_fod`
exec: Operational · Financial
- 🟢 Temp protection funded fairly; backcharges require notice + cure.
- 🔴 The Company blamed/backcharged for damage by others or jobsite final clean it didn't cause; cleanup charged on short/no notice.
- **Detection cues:** "protection of work", "final cleaning", "FOD", "clean up … charge all costs", "24 hours' notice … no notice upon the second occurrence".

### Punch Lists `punch_lists`
exec: Operational
- 🟢 Reasonable closeout items, defined window.
- 🟡 Extended punch list.
- 🔴 Open-ended obligations; punch items block substantial completion.
- **Detection cues:** "punch list", "punchlist", "minor … items", "completed to … satisfaction".

### Warranty Period `warranty`
exec: Operational
- 🟢 1 year from **the Company's scope** substantial completion, **or the manufacturer's warranty period, whichever is less** (recommended standard).
- 🟡 Up to **2 years** from the Company's scope completion (documented walk-back ceiling).
- 🔴 Tied to **Project/owner** substantial completion or occupancy; "greater of one year or the Contract Documents"; warranty-restart-on-each-repair; 24-hr call-back self-help + backcharge; performance warranty conflated with workmanship.
- **Detection cues:** "warranty", "greater of one year", "Substantial Completion of the Project", "owner occupancy", "manufacturer's warranties".
- **Redline [proven]:** "Warranty obligations shall not exceed two years from substantial completion of Trade Contractor's Work unless expressly stated in Exhibit A; in no event shall warranty exceed one year or the manufacturer's warranty period, whichever is less, except as agreed."

---

## D. Legal / Risk Allocation

### Indemnification + Duty to Defend `indemnification`
`never_auto_green` · exec: Legal
- 🟢 Indemnify only to the extent of the Company's own negligence; no duty to defend others on mere allegation.
- 🟡 Broad but limited.
- 🔴 Broad-form (indemnify others for their own negligence) **or** a duty to **defend on mere allegation** (separate from and broader than indemnity).
- **Detection cues:** "defend, indemnify and hold harmless", "to the fullest extent", "caused in whole or in part", "arising out of … the Work", "any indemnified party under the Prime Contract".
- 🟡 **Hybrid (common):** indemnity is proportionate ("to the extent caused by Trade Contractor" — good) **but** bundles an **unqualified duty to defend** and/or an open-ended indemnitee class ("any indemnified party under the Prime Contract"), plus a savings clause preserving other indemnity obligations. Rate 🟡 + **HUMAN-VERIFY** — the proportionate indemnity doesn't cure the broad defense duty.
- **Carve-out check:** even a "to the extent caused by Trade Contractor" indemnity should still exclude others' own negligence, cap the defense duty to the Company's proportionate fault, and close the open-ended Prime-indemnitee class.
- **Redline [proven]:** "Trade Contractor shall not indemnify any Indemnified Party for that party's own negligence, gross negligence, willful misconduct, or breach of contract." Plus [standard]: "Trade Contractor shall indemnify only to the extent damages are caused by Trade Contractor's negligence" — and the duty to defend shall be limited to the Company's proportionate share and shall not arise on mere allegation.

### Consequential Damages Waiver `consequential_damages`
`never_auto_green` · exec: Legal
- 🟢 Mutual waiver of consequential/incidental/special damages.
- 🟡 One-sided waiver.
- 🔴 The Company liable for consequential damages, **or** a carve-out that flows the owner's/GC's consequential or LD damages back through (guts the waiver). High-value end-use (e.g., mission-critical facilities) = potential large lost-production tail; auto-escalate.
- **Detection cues:** "consequential, incidental, or special damages", "in the absence of a full waiver … in the Prime Contract", "to the same extent as Contractor is liable to Owner", "not … waiving any claim for liquidated damages".
- **Redline [proven]:** "Trade Contractor shall not be liable for consequential, incidental, special, indirect, or lost-profit damages under any circumstances."

### Limitation of Liability `limitation_liability`
`never_auto_green` · exec: Legal
- 🟢 Liability capped (e.g., to Contract Sum or insurance proceeds).
- 🟡 Partial limitation.
- 🔴 Unlimited exposure. ⚪ **Not addressed = Red** — absence of a cap is the finding.
- **Detection cues:** "limitation of liability", "liability shall not exceed", "cap", absence thereof.
- **Redline [draft]:** "Trade Contractor's aggregate liability under this Agreement shall not exceed the Contract Sum, except for claims covered by insurance."

### Termination for Convenience `termination_convenience`
`never_auto_green` · exec: Legal · Financial
- 🟢 Paid for work + OH&P + non-returnable materials + demob + cancellation costs.
- 🟡 Paid for work only.
- 🔴 No OH&P; excludes placed-PO cancellation/restocking (severe for long-lead equipment).
- **Detection cues:** "terminate … for convenience", "pay … for all Work satisfactorily performed", "mitigate its costs".
- **Redline [proven]:** "Upon termination for convenience, Contractor shall pay Trade Contractor for: work performed; materials ordered and non-returnable; reasonable demobilization costs; reasonable cancellation costs; and reasonable overhead and profit on work performed."

### Termination for Cause / Default `termination_cause`
`never_auto_green` · exec: Legal · Operational
- 🟢 ≥10-day written cure + paid for work performed; objective, documented default standard.
- 🟡 7-10 day cure.
- 🔴 Cure <7 days; "sole discretion" / "reasonably believes not capable" triggers; sub liable for **cost-to-complete** without cap/offset.
- **Detection cues:** "default", "grace period of two working days", "reasonably believes … not capable", "all costs to complete … borne by Trade Contractor", "immediately upon … written notification".
- **Redline [proven]:** Default = "Contractor reasonably determines, based on documented facts, that Trade Contractor has materially failed to perform"; cure = "seven business days, or such longer period as reasonably necessary if cure is diligently pursued."

### Suspension Rights `suspension`
exec: Financial
- 🟢 The Company may suspend for non-payment.
- 🟡 Restricted.
- 🔴 No right to suspend for non-payment.
- **Detection cues:** "suspend", "stop work", "shall continue to perform", "shall not suspend performance".
- **Redline [standard]:** "Trade Contractor reserves the right to suspend Work for non-payment after written notice."

### Right to Supplement / Takeover Without Termination `supplement_takeover`
exec: Operational · Financial
- 🟢 Only after default + cure; reasonable cost.
- 🔴 GC may supplement/take over and charge back (often cost + markup) with little/no notice or cure.
- **Detection cues:** "supplement", "take over the work", "hire another trade contractor … at Trade Contractor's cost", "charge … plus ___%".

### Change Orders `change_orders`
exec: Schedule · Financial
- 🟢 Written approval or constructive-change recognized; defined review window.
- 🟡 Formal approval preferred.
- 🔴 Must perform extra/disputed work without compensation assurance ("proceed under protest"); no review/approval window; only an officer can approve.
- **Detection cues:** "Change Order", "prior written approval", "no oral", "proceed", "constructive change".
- **Redline [draft]:** "Disputed change-order work shall not be required to proceed without written direction and a reservation of Trade Contractor's right to equitable adjustment; Change Orders shall be reviewed within [10] days."

---

## E. Insurance & Bonding

### Professional Liability / E&O `professional_liability`
exec: Legal
- 🟢 Not required.
- 🟡 Project-specific.
- 🔴 Mandatory E&O where no design responsibility exists.
- **Detection cues:** "professional liability", "errors and omissions", "E&O".

### Pollution / Asbestos Insurance `pollution_asbestos`
exec: Legal
- 🟢 Not required.
- 🟡 Project-specific (e.g., pollution $2M when environmental exposure is in scope).
- 🔴 Mandatory pollution/asbestos with no related scope.
- **Detection cues:** "pollution liability", "asbestos", "environmental exposure".

### Performance / Payment Bonds `bonds`
exec: Operational · Financial
- 🟢 Not required.
- 🟡 Paid by customer.
- 🔴 Required without compensation. (Pricing note: bond cost ≈ ~2.5% of Contract Sum — add to the bid if required.)
- **Watch:** a right to demand a **warranty bond even after a default is cured** is an added, uncompensated bonding cost — flag it.
- **Detection cues:** "payment and performance bond", "surety", "co-obligees", "bonds in the amount of the Work", "warranty bond".

### Additional Insured / Primary-Noncontributory / Waiver of Subrogation `insurance_endorsements`
`never_auto_green` · exec: Legal
- 🟢 Within the Company's program; standard ongoing/completed-ops AI.
- 🟡 Reviewable (route Exhibit C to the broker).
- 🔴 AI on primary & non-contributory basis + waiver of subrogation + multi-year completed-ops tail, **and/or** "insurance independent of / does not limit indemnity."
- **Detection cues:** "additional insured", "primary and non-contributory", "waiver of subrogation", "CG 20 10", "CG 20 37", "completed operations", "tail".
- **Note:** the real requirements usually live in the **insurance exhibit** — confirm against the Company's program (loop in your broker).
- **Redline [proven]:** "Additional insured status shall not increase Trade Contractor's contractual liability beyond the limits specifically required under this Agreement; Trade Contractor's insurance obligations are limited to coverage commercially available at reasonable rates."

### Required Limits vs Program `insurance_limits`
exec: Legal
- 🟢 Limits ≤ the Company's program.
- 🔴 Limits exceeding the Company's program, "whichever is most stringent" vs the Prime, or a multi-year completed-ops tail.
- **Detection cues:** "limits of not less than", "whichever is most stringent", "amounts required in the Prime Contract".

---

## F. Dispute Resolution & Governing Law

### Governing Law `governing_law`
`state_law_dependent` · exec: Legal
- Identify the state; drives Step 2. Surface enforceability findings (pay-if-paid, anti-indemnity, prompt-pay).
- **Detection cues:** "shall be governed by … laws of the State of", "entered into in the State of".

### Jurisdiction / Venue / Forum Selection `venue`
`state_law_dependent` · exec: Legal
- 🟢 The Company's home state or a mutually agreed neutral (see `config.md`), **pinned** in the contract.
- 🟡 Other named state.
- 🔴 Foreign/unfavorable venue, **or** venue left to GC/owner choice or undetermined (must be pinned before signing).
- **Carve-out check:** a facially-Green home-state venue can be overridden by (a) an owner-dispute clause routing Owner-involved Claims into the Prime's procedure with the sub bound by the GC↔Owner outcome, and (b) "if the Project is outside [home state], the project state's law/forum control." Read venue with the dispute-resolution carve-outs and project location.
- **Detection cues:** "venue", "jurisdiction", "Circuit Court of ___ County", "inconvenient forum", "if the location of the Project is outside of".
- **Redline [standard]:** "Venue shall be the state of the Project or the Company's home state as mutually agreed, fixed at execution and not subject to later unilateral selection."

### Dispute-Resolution Election (litigation vs arbitration) `dr_election`
exec: Legal
- 🟢 Mutually agreed method.
- 🔴 GC alone elects litigation or arbitration.
- **Detection cues:** "at Contractor's sole discretion, by litigation or by arbitration".
- **Redline [proven]:** "The parties shall mutually agree upon litigation or arbitration. If no agreement is reached, arbitration shall apply."

### Jury Waiver `jury_waiver`
exec: Legal
- 🔴 Waiver of jury trial.
- **Detection cues:** "waive … jury", "jury trial waiver".

### Fee-Shifting `fee_shifting`
exec: Legal
- 🟢 Each party bears its own fees.
- 🟡 Mutual prevailing-party fees.
- 🔴 One-way attorneys' fees to the GC.
- **Detection cues:** "prevailing party", "attorneys' fees", "shall recover from the other party".
- **Redline [proven]:** "Each party shall bear its own attorney fees except where otherwise awarded by law."

### Owner-Dispute / Consolidation Control `owner_dispute_control`
exec: Legal
- 🔴 Owner-involved Claims resolved per the Prime; the Company bound by the GC↔Owner determination; GC may join/consolidate; the Company must continue work and not suspend during a Claim.
- **Detection cues:** "if the Claim involves the Project Owner", "consolidate", "stayed pending", "bound … to the same extent that Contractor is bound to Project Owner".

### Limitations / Time-Bar on Claims `limitations_bar`
`state_law_dependent` · exec: Legal
- 🟢 No contractual shortening; clause tracks/tolls the statutory period.
- 🔴 Any contractual shortening below the statutory limitations period (silently bars latent/final-account claims).
- **Boundary note:** a short **claim-notice-or-waived** window (e.g., "14-day claim or waiver") belongs under `notice_claim`, **not** here — don't double-count. This row is only for clauses that shorten the *statute of limitations* itself. A clause that merely tolls the SOL during mediation is 🟢.
- **Detection cues:** "any claim must be brought within ___", "shortened", "statute of limitations", "barred by the applicable statute".

### Continue Work During Dispute `continue_work`
exec: Legal · Financial
- 🔴 Mandate to keep performing regardless of nonpayment/dispute (pairs with no suspension right).
- **Detection cues:** "shall continue to perform", "shall not suspend performance … during the pendency of a Claim".

---

## G. Administrative

### Meeting Attendance Penalties `meeting_penalties`
exec: Financial
- 🟢 None.
- 🟡 Minimal.
- 🔴 Financial penalties for meetings (e.g., $250/occurrence — an unusual structure worth flagging).
- **Detection cues:** "fine", "penalty", "per occurrence", "failure to attend".
- **Redline [draft]:** "Require a written warning before any fine is assessed, or strike the provision."

### Audit Rights `audit_rights`
exec: Legal
- 🟢 Limited to project records.
- 🔴 Broad audit rights beyond project records.
- **Detection cues:** "audit", "books and records", "supporting data".

### Assignment / Anti-Assignment `assignment`
exec: Legal
- 🟡 One-sided assignment to the GC/owner; conditional assignment to Owner.
- 🔴 Anti-assignment of warranty, or assignment forced without consent.
- **Detection cues:** "assign", "third-party beneficiary", "take an assignment".

### Confidentiality / Publicity / Marketing-Use `confidentiality_publicity`
exec: Operational
- 🟢 Standard project confidentiality; the Company keeps the right to reference the project in its portfolio/marketing with reasonable limits.
- 🟡 Confidentiality survives a defined period; publicity requires GC consent not unreasonably withheld.
- 🔴 Bars the Company from referencing the project at all, or from using photographs for promotional materials; broad survival (longer of X years or the Prime period).
- **Material where the Company markets its project portfolio** — rate accordingly.
- **Detection cues:** "confidential", "shall not … disclose the existence of the Project", "photographs … for promotional materials", "survive … years".
- **Redline [draft]:** "Trade Contractor may reference the Project and use non-confidential photographs of its own Work in its marketing/portfolio, subject to reasonable protection of Owner's proprietary information."

### Non-Disparagement `non_disparagement`
exec: Legal
- 🟡 Mutual, narrowly scoped.
- 🔴 Broad or one-sided non-disparagement.
- **Detection cues:** "disparaging", "defamatory", "comments … concerning the other party".

### Tax Assumption `tax_assumption`
exec: Financial
- 🟢 Each party responsible for its own taxes; sales/use tax included in the Contract Sum as quoted.
- 🔴 The Company assumes additional sales/use tax (plus interest/penalties) "assessed directly or indirectly against Contractor" — uncapped exposure.
- **Detection cues:** "sales and/or use tax", "assessed directly or indirectly", "interest and penalties".
- **Redline [draft]:** "Trade Contractor is responsible only for taxes on its own Work as quoted, not for taxes assessed against Contractor or arising from Contractor's or Owner's acts."

### Joint-Employer / Labor Indemnity `joint_employer`
exec: Legal
- 🟡 Standard independent-contractor + wage-compliance representations.
- 🔴 The Company indemnifies for any joint-employer finding, or broad labor-law indemnity reaching beyond its own employees.
- **Detection cues:** "joint-employer", "wages and benefits", "indemnify … labor laws".

### Authority to Bind / Modification Severance `authority_to_bind`
exec: Legal
- 🟡 Standard "amendment in a writing signed by both parties."
- 🔴 Only GC officers may amend; unauthorized modifications "severed … and not enforced" (voids field-negotiated changes); the GC's PM can approve COs but the Company's cannot bind.
- **Detection cues:** "only … when signed by … President/CEO/CFO", "severed from the remaining terms … not be enforced", "authorized representative".
- **Redline [draft]:** "Scope/cost/time changes acknowledged in writing by either party's project manager shall be binding."

### Administrative Red Flags `admin_flags`
exec: Operational
- 🔴 Blank/incomplete exhibits, references to an un-provided prime, undefined or conflicting terms, requirements exceeding project value, $0.00 / placeholder fields in a live contract.
- **Detection cues:** "[[", "TBD", blank exhibits, "$0.00", placeholder tokens.
- **Note:** ties to the Step 1 completeness gate and the memo's Request-for-Documents list.

---

## Living document
When you encounter a recurring issue not covered above, propose a new provision row (same format) at the end of the review for the rubric owner to merge. Bump the version and add a changelog entry in `README.md` when the rubric changes.
