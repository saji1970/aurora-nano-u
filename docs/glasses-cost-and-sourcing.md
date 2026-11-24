# Aurora glasses: development cost, sourcing and manufacturing

This estimates what it costs to take the Aurora glasses from the [main-board design](glasses-board.md) and [packaging plan](glasses-packaging.md) to a certified product, and where to buy the parts and build it.

**Headline (standalone 5G version, first product):**

| | Low | High |
| --- | --- | --- |
| One-time development cost (engineering, prototypes, tooling, certification, 20% contingency) | **about $4M** | **about $11.2M** |
| Time from start to first shipments | 18 months | 30 months |
| Parts and assembly per unit, prototype builds (10–100 units) | $2,000 | $4,500 |
| Parts and assembly per unit, volume (10,000–100,000 units) | $505 | $855 |
| Likely retail price at a normal 2.5–3× markup on volume cost | $1,300 | $2,500 |

Dropping standalone 5G (pairing with a phone over Bluetooth and Wi-Fi instead) cuts the one-time cost to about **$3M–7M** and the volume unit cost by about **$70–110** (modem, RF front end and cellular royalties).

The estimate includes the [camera system](glasses-camera.md) (12 MP camera, privacy LED, tracking camera) and the [Android OS and apps plan](glasses-software-platform.md) (store, SDK, launch apps).

These are planning ranges, not quotes. They come from typical industry rates for phone and wearable programs, published certification costs, and teardown cost shares of similar glasses. Real numbers depend on volume commitments, which suppliers agree to work with you, and how many prototype rounds the design needs. Every number should be replaced by a quote before it is used to raise money or sign a contract.

## Assumptions

- **The product is the one in the existing docs:** Snapdragon XR2 Gen 2-class SoC, 16 GB LPDDR5X, 256 GB UFS 4.0, two full-color microLED projectors with waveguides, a 12 MP camera with a hardware privacy LED and a tracking camera, temple touchpad, 5G sub-6 GHz modem, Wi-Fi 7 and Bluetooth, cameras, two arm batteries, two rigid boards joined by flex.
- **The Aurora-Nano chip is not in the first product.** The 130 nm Aurora-Nano-U in this repository is a teaching tapeout, and the 3 nm glasses version is a design target. A 3 nm tapeout alone costs tens of millions of dollars, so it is left out here and the SoC's own NPU runs the AI. The board can keep a footprint for it for a later version.
- **Sold in the US and EU first**, with US carrier approval on one to three networks.
- **Built by a contract manufacturer or ODM**, not in your own factory.
- **Software is Android (AOSP) on Qualcomm's board support package**, with your own launcher, store and apps, not a new operating system; Google's Android XR is pursued in parallel ([software plan](glasses-software-platform.md)).
- **Prices are late-2026 US dollars.** Memory prices were high through 2025–2026, so the memory lines may move the most.

## One-time development cost (NRE)

| Item | What it covers | Low | High |
| --- | --- | --- | --- |
| Industrial and mechanical design | frame styling, CAD of arms and hinges, thermal design, fit testing | $250k | $600k |
| Electronics and PCB design | schematics, 10–12 layer HDI layout of both boards, rigid-flex, signal and power integrity | $400k | $1.0M |
| RF and antenna design | antennas in the frame for 5G, Wi-Fi, Bluetooth and GPS, tuning, SAR (radio exposure to the head) optimisation | $150k | $400k |
| Optics integration | projector-to-waveguide alignment, display calibration, eye-box and brightness tuning | $300k | $1.0M |
| Software | Android board bring-up, display, camera, touch and audio drivers, power and thermal tuning, launcher, over-the-air updates, plus the app store, developer SDK and ten launch apps ([software plan](glasses-software-platform.md)). About 10–17 engineers for 12–18 months, and the largest single cost | $1.3M | $3.6M |
| Camera tuning and test | image-quality tuning of the camera ISP for the chosen sensor and lens; factory camera test fixtures ([camera](glasses-camera.md#cost)) | $150k | $400k |
| Program management, quality and reliability testing | drop, sweat, bend, hinge-cycle and battery tests; supplier management | $200k | $500k |
| Prototype builds | three build rounds (EVT, DVT, PVT) of 20–100 units each, at prototype unit costs | $200k | $700k |
| Production tooling | injection molds for the frame and arms, hinge tooling, custom battery cell tooling, test and assembly fixtures | $150k | $500k |
| Certification | see the next table | $250k | $900k |
| **Subtotal** | | **$3.35M** | **$9.6M** |
| Contingency, 20% | at least one extra board or optics spin is normal for a first product | $0.65M | $1.6M |
| **Total** | | **about $4M** | **about $11.2M** |

### Certification

| Approval | Why it is needed | Low | High |
| --- | --- | --- | --- |
| FCC (US) radio approval, including SAR | every radio in the product; SAR is strict for a device worn on the head | $40k | $100k |
| CE / RED (EU), UKCA | radio, electrical safety, EMC and SAR for Europe and the UK | $30k | $80k |
| PTCRB and GCF | cellular industry approval that carriers require before network testing | $50k | $200k |
| Carrier approval (Verizon, AT&T, T-Mobile) | each carrier's own lab and field tests, about $50k–250k per carrier | $50k | $400k |
| Battery safety (UN 38.3, IEC 62133) | required to ship lithium cells by air and sell them | $10k | $25k |
| Eye and display safety (IEC 62471) | light from the projectors entering the eye | $10k | $20k |
| Bluetooth SIG and Wi-Fi Alliance | the right to use the logos and claim compliance | $15k | $30k |
| Other markets (Canada ISED, Japan, Korea, Australia) | optional for launch | $0 | $45k |
| **Total** | | **about $250k** | **about $900k** |

Published figures for PTCRB alone run from about $16k–20k for a simple data-only device to well over $100k for a full phone-class device, and the process takes about two months ([emnify](https://www.emnify.com/blog/ptcrb), [Milburn](https://jjmilburn.github.io/2017/03/18/Cellular-Certification-in-USA)). Without 5G, the PTCRB, GCF and carrier lines go away, and certification drops to about **$100k–250k**.

### Per-unit royalties

Selling a 5G device also means paying cellular patent royalties, about **$10–20 per unit** in total (Qualcomm's license plus other patent pools). The Android Google apps and services (GMS) license is negotiated with Google and needs its own compatibility testing; plain AOSP without Google Play avoids it.

## Bill of materials per unit

Prototype prices assume buying tens of parts through a design house or as samples; volume prices assume 10,000–100,000 units a year with direct supplier agreements.

| Part | Prototype (10–100 units) | Volume (10k–100k units) |
| --- | --- | --- |
| SoC + matched PMICs (XR2 Gen 2-class) | $250–400 | $120–180 |
| 16 GB LPDDR5X (package-on-package) | $80–120 | $45–70 |
| 256 GB UFS 4.0 | $35–50 | $20–30 |
| 5G modem, RF front end, antennas | $120–200 | $60–90 |
| Wi-Fi 7 + Bluetooth combo | $15–25 | $8–12 |
| Two full-color microLED projectors | $300–800 | $80–160 |
| Two waveguides | $400–1,500 | $60–150 |
| Cameras: 12 MP RGB, tracking camera, privacy LED ([camera](glasses-camera.md#cost)) | $32–61 | $14–22 |
| Audio, sensors, touchpad | $20–35 | $10–15 |
| Two custom battery cells with protection | $20–40 | $6–10 |
| Boards: two HDI rigid boards, hinge and frame flexes | $150–400 | $25–45 |
| Frame, hinges, lenses, heat spreaders (CNC or 3D-printed at prototype, molded at volume) | $200–500 | $15–30 |
| Assembly, optical alignment, test, packaging | $150–300 | $15–30 |
| Charging case and cable | $30–60 | $8–15 |
| **Total** | **about $2,000–4,500** | **about $505–855** |

The display system (projectors plus waveguides) is the biggest cost, as it is in shipping display glasses: teardown analysis puts display parts at about 51% of Meta Ray-Ban Display's bill of materials and Qualcomm parts at about 16% ([TechInsights](https://www.techinsights.com/blog/meta-ray-ban-display-teardown-reveals-more-meets-eye)). Two ways to cut it: a single display in one eye (as Meta does), or monochrome green microLED, which costs a fraction of full color.

## Where to source the parts

| Part | Where to get it | Notes |
| --- | --- | --- |
| Qualcomm SoC, PMIC, modem, Wi-Fi | Qualcomm directly (needs a business agreement and usually a volume forecast), or through an authorized design house such as **Thundercomm** or **Lantronix**, or an ODM that already holds a Qualcomm license such as **Goertek** | Qualcomm does not sell XR chips through retail distributors, and its datasheets and software need an NDA. A small company normally gets access through a design house or ODM. Qualcomm's XR2 Gen 2 reference design is the fastest starting point |
| LPDDR5X and UFS | Samsung, Micron, SK hynix, through Arrow, Avnet, WPG or Future Electronics | must match the memory Qualcomm has validated for the SoC |
| microLED projectors | **JBD (Jade Bird Display)**, Shanghai, the main volume supplier of tiny microLED panels and projectors for glasses | LCoS projectors (OmniVision, Himax) are cheaper and brighter in color today, if microLED is not a must |
| Waveguides | **Lumus** (Israel), **DigiLens** (US), **Vuzix** (US, also sells waveguides to other brands), **Dispelix** (Finland), Goolton and Lochn (China) | ask for evaluation kits first; waveguide yield drives price |
| Batteries | custom thin cells from **ATL**, **Sunwoda**, **EVE**, **Grepow**, or **Varta** | custom cell shapes need tooling and 3–6 months |
| Antennas | **Taoglas**, **Ignion**, Sunway | they also do custom antenna design and tuning |
| Passives, connectors, sensors | Digi-Key, Mouser (US), LCSC (China) | |
| Certification labs | **Element** (which includes PCTEST, a lab the US carriers use), **UL**, **TÜV SÜD**, **Intertek**, **SGS**, **Eurofins**, **Bureau Veritas** | pick one lab that can do FCC, SAR, PTCRB and carrier testing together |

### A cheaper SoC to consider

The XR2 Gen 2 is built for headsets that draw 5–10 W. Qualcomm's **Snapdragon AR1+ Gen 1** is built for glasses: smaller, cooler, and able to run a 1B-parameter model on the glasses ([Qualcomm](https://www.qualcomm.com/xr-vr-ar/products/ar-series/snapdragon-ar1-plus-gen-1-platform)). It has no built-in 5G and is meant to pair with a phone, but it would solve much of the power and heat problem in the [power budget](glasses-board.md#the-power-budget-is-the-main-risk), and it is the chip most display-glasses makers use.

## Where to build it

| Stage | Option | Who |
| --- | --- | --- |
| Early prototypes (boards) | US quick-turn HDI fabrication and assembly | **Sierra Circuits** (HDI and rigid-flex), **Screaming Circuits**, **MacroFab** |
| | China prototype fabrication and assembly, cheaper and slower to ship | **PCBWay**, **Seeed Fusion**; phone-class HDI usually needs a larger board house |
| Volume boards | phone-grade HDI and rigid-flex board makers | **Unimicron**, **Zhen Ding**, **Compeq**, **AT&S** (normally reached through your ODM) |
| Whole product (ODM: they help design and then build) | smart-glasses and XR specialists, mostly in China | **Goertek** (Weifang; makes VR headsets and glasses for large brands and builds Qualcomm's XR reference designs), **Luxshare**, **Thundercomm** (Qualcomm software and hardware partner) |
| | phone and wearable ODMs | **Huaqin**, **Longcheer**, **Wingtech** |
| Whole product (contract manufacturer: they build your design) | Asia | **Foxconn (FIH)**, **Pegatron**, **Quanta** |
| | US or Mexico, if made-in-America or tariff exposure matters | **Jabil**, **Flex**, **Benchmark** (expect higher unit cost and less glasses-specific experience) |

Most ODMs want a minimum order of about **10,000–50,000 units** and an NRE payment up front. Shenzhen and Dongguan have the deepest supply chain for glasses parts and the fastest prototype turns; Vietnam is the usual second site for tariff reasons. US-made units typically cost 20–40% more to assemble.

## Recommended path

| Phase | What happens | Rough cost | Time |
| --- | --- | --- | --- |
| 0. Proof of concept | Qualcomm development kit or a design house's XR board, plus a waveguide and projector evaluation kit on a 3D-printed frame. Proves the display, apps and battery life before any custom board | $50k–150k | 3–4 months |
| 1. Pick the path | Answer the [open questions](glasses-board.md#open-questions): standalone 5G or phone pairing, 16 or 8 GB, XR2 Gen 2 or AR1+. Get quotes from two or three ODMs | — | 1 month |
| 2. Engineering prototypes (EVT) | custom boards and frame, first software | $1M–3M | 6–9 months |
| 3. Design and production validation (DVT, PVT) | fixes, tooling, reliability tests, certification | $1.5M–5M | 6–12 months |
| 4. Mass production | first production run with the ODM | unit cost × volume | ongoing |

Working through an ODM that already has a Qualcomm glasses reference design (for example Goertek or Thundercomm) is the fastest and cheapest route for a first product. It can bring the one-time cost toward the low end of the range, because their board, RF and Android work is reused, in exchange for a volume commitment and less control over the design.

## Next steps

- [ ] Decide standalone 5G or phone pairing; it is the single biggest swing in cost, power and weight.
- [ ] Ask Qualcomm, Thundercomm and Goertek for access to their glasses and XR reference designs.
- [ ] Order microLED and waveguide evaluation kits from JBD and one waveguide supplier.
- [ ] Request quotes from two ODMs and one certification lab to replace these ranges with real numbers.
