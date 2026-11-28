# Aurora glasses: build package

This is the document to start building from. It turns the [main-board design](glasses-board.md), the [packaging plan](glasses-packaging.md), the [camera system](glasses-camera.md) and the [Android OS and apps plan](glasses-software-platform.md) into a shopping list, a wiring plan, a set of sizes and an order of work.

It starts with the **proof of concept (POC)**: one to three working pairs you can wear, used to prove the display, apps, battery life and heat before anyone pays for a custom board.

All prices are late-2026 planning estimates for buying one to three of each part, not quotes. Part numbers are real parts of the right class, picked so a schematic can start, but each one must be checked against its current datasheet, stock and the ODM's or SoC vendor's approved list before it is ordered in quantity.

## 1. Three ways to build the POC

| | **Route A: tethered app POC** | **Route B: ODM-board POC (recommended)** | **Route C: Qualcomm reference POC** | (Custom board, the full design) |
| --- | --- | --- | --- | --- |
| What it is | off-the-shelf display glasses on a USB-C cable to an Android phone or board that runs our launcher and apps | a ready-made Android AR-glasses main board from a Shenzhen ODM (the class described in the eeworld article), with two micro-OLED displays, cameras and batteries in our own 3D-printed frame | Qualcomm AR1+ or XR2 Gen 2 reference hardware through a design house or ODM, with JBD microLED and waveguide evaluation kits | the [main-board design](glasses-board.md): XR2 Gen 2-class SoC, 16 GB, 5G, microLED waveguides, two custom HDI boards |
| Proves | the launcher, touchpad navigation, apps, AI assistant and captions | all of route A, plus a standalone pair on the head: real battery life, heat, weight, camera, GPS and sensors | the chosen production chip and optics; real microLED brightness and waveguide image | the product |
| Doesn't prove | form factor, battery, heat | the Qualcomm chip, microLED and waveguides, 5G | custom-board fit in the arm | — |
| Cost for one to three pairs | **about $1.5k–4k** | **about $8k–25k** | **about $50k–150k** | $3M+ in engineering before the first unit ([cost estimate](glasses-cost-and-sourcing.md)) |
| Time to first wearable | 2–4 weeks | 2–4 months | 3–6 months, after the NDA and access | 12–18 months |
| Who can do it | you, plus one Android developer | you, one Android or BSP engineer, one mechanical designer, the ODM's support | needs a Qualcomm business agreement or a design house (Thundercomm, Goertek) | the full team in the [funding plan](glasses-funding-requirement.md) |

**Recommendation:** start route A this week so app work starts at once, and run route B in parallel as the real POC. Route B gets a standalone pair on your head for about $8k–25k, which is the "proof of concept worn on the head" promised in the Indiegogo campaign copy and the funding plan. Route C follows once there is money and a Qualcomm or ODM agreement. The Android apps written in routes A and B carry over unchanged to C and to the final product.

## 2. POC bill of materials

### Route A: tethered app POC

| # | Part | Example | Qty | Unit price | Where to buy |
| --- | --- | --- | --- | --- | --- |
| A1 | Display glasses with USB-C DisplayPort input (micro-OLED + birdbath optics, 1920 × 1080 per eye) | any current consumer "AR display glasses" with a USB-C video input | 1 | $300–500 | Amazon, Best Buy, the maker's store |
| A2 | Android phone with USB-C DisplayPort output and Android 14 or later (sends a second screen to the glasses) | a recent Pixel, Samsung Galaxy S or similar | 1 (you may already have one) | $0–700 | any phone store |
| A3 | Or, instead of a phone: Android single-board computer with HDMI or DP out (RK3588 class) | Radxa Rock 5B, Khadas Edge2, Orange Pi 5 | 1 | $120–250 | Radxa, Khadas, AliExpress, Amazon |
| A4 | Bluetooth touchpad or a small trackpad, as a stand-in for the temple touchpad | any Bluetooth trackpad or media remote with arrow keys | 1 | $20–60 | Amazon |
| A5 | USB-C camera module for AI-vision tests | 8–12 MP UVC camera (Arducam UVC series) | 1 | $30–70 | Arducam, Amazon |
| A6 | USB-C hub with power pass-through, cables | | 1 | $30–60 | Amazon |
| A7 | Developer computer for Android Studio (16 GB RAM or more) | you likely have one | 1 | $0 | |
| | **Route A total** | | | **about $1.5k–4k**, or under $1k with a phone you already own | |

### Route B: ODM-board POC (one pair; three pairs is about 2.5×)

| # | Part | Example part / class | Qty | Unit price | Where to buy |
| --- | --- | --- | --- | --- | --- |
| **Compute** | | | | | |
| B1 | Android AR-glasses main board: 8-core SoC, 4 GB RAM, 32–64 GB storage, Android 13+, dual MIPI DSI for two micro-OLEDs, dual MIPI CSI, 4G, Wi-Fi 5, Bluetooth 5, GNSS, IMU, magnetometer, barometer, light and proximity sensors, charger and fuel gauge, about 55 × 16 × 4 mm | MediaTek MT8781 / MT8768 (Helio G-series) class boards sold as "AR glasses motherboard" or "smart glasses Android solution" | 2 (one spare) | $200–600 | Shenzhen AR and smart-glasses ODMs on Alibaba and Global Sources; ask for the board, schematic, BSP source and a debug board in one deal |
| B2 | BSP / SDK access and engineering support from the ODM (kernel and device-tree source, display and camera drivers) | | 1 | $0–10,000 | the same ODM; some include it with a sample order, some charge a one-off fee |
| B3 | Debug / breakout board for the main board (USB, UART console, boot-mode key) | usually offered by the ODM | 1 | $50–200 | the same ODM |
| **Display** | | | | | |
| B4 | Micro-OLED panels, 0.39 in, 1920 × 1080, MIPI or the ODM's bridge | **Sony ECX343EN** (or SeeYA SY049WDM02, as in the eeworld board) | 2 + 1 spare | $250–500 | Framos, Macnica (Sony's distributors); the ODM often sells panels matched to its board |
| B5 | Birdbath or freeform optics, one per eye, matched to the 0.39 in panel | birdbath optical module | 1 pair + spare | $100–400 a pair | AR optics makers on Alibaba; the ODM usually has a partner |
| B6 | Panel flex cables (panel to main board) | supplied with the panel or made by the ODM | 2 | $10–40 | ODM |
| **Cameras** | | | | | |
| B7 | 12–13 MP MIPI camera module, wide lens, matched to the board's driver | Sony IMX681 or a 13 MP module the ODM already supports | 1 + spare | $15–40 | ODM; camera-module makers on Alibaba |
| B8 | Global-shutter mono tracking camera | OmniVision OV9281 / OV9282 module | 1 | $20–50 | Arducam, ODM |
| B9 | Privacy LED, white 0402/0603, with diffuser, plus load switch | TI **TPS22916** load switch feeding the camera rail and LED | 1 | $1–3 | Digi-Key, Mouser, LCSC |
| **Audio and input** | | | | | |
| B10 | Micro speakers, about 15 × 11 mm, 0.5 W | 1511-class micro speaker (AAC, Goertek, or generic) | 2 | $2–8 | ODM, Alibaba, Digi-Key |
| B11 | MEMS microphones (if not on the board) | Infineon **IM69D130**, PDM | 2–3 | $2–4 | Digi-Key, Mouser |
| B12 | Temple touchpad: capacitive trackpad controller and a flex sensor pad about 55 × 12 mm | Azoteq **IQS7211E** trackpad controller with a custom sensor flex, or the ODM's touch FPC | 1 | $20–80 (flex made to order) | Azoteq via Digi-Key; flex from PCBWay or JLCPCB |
| B13 | Buttons: power, camera shutter, volume up/down | C&K **KMR2** side-actuated tact switches | 4 | $0.5–1 | Digi-Key, Mouser |
| B14 | Fold / in-case sensor | TI **DRV5032** Hall switch + 2 × 1 mm magnet | 1 | $1–2 | Digi-Key |
| **Power** | | | | | |
| B15 | Battery cells, one per arm, thin Li-polymer with protection board | 601045 / 501045-class pouch cells (about 5–6 × 10 × 45 mm, 200–300 mAh each) | 2 + 2 spare | $5–15 | Grepow, Alibaba cell makers, Adafruit for testing |
| B16 | Magnetic pogo charging connector, 2–4 pin | Mill-Max magnetic spring-pin connectors | 1 pair | $10–30 | Digi-Key, Mouser |
| B17 | Charging cradle: USB-C PD input board feeding the pogo pins | small USB-C 5 V board for the POC; real case later | 1 | $10–30 | Adafruit, AliExpress |
| B18 | Skin-temperature sensors, one per arm | Murata **NCP03XH103** 10 kΩ NTC thermistor | 2 | $0.2 | Digi-Key |
| **Mechanical and wiring** | | | | | |
| B19 | Frame front, arms, hinges: SLA or MJF 3D prints, three iterations | from the CAD of [section 5](#5-mechanical-sizes) | 3 sets | $60–250 a set | JLCPCB 3D, PCBWay, Xometry, Protolabs |
| B20 | Hinge and frame flex cables (custom polyimide) | 2-layer flex, 0.1 mm, made from our drawings | 1 batch of 5 | $100–400 | PCBWay, JLCPCB flex |
| B21 | Spring hinges, screws, heat-spreading graphite sheet, foam, adhesives | | 1 set | $30–80 | Alibaba, Digi-Key (graphite: Panasonic PGS) |
| **Tools (one-off, reused later)** | | | | | |
| B22 | Power profiler for battery-life measurement | Nordic **PPK2** or Joulescope | 1 | $100–900 | Digi-Key, Mouser |
| B23 | Thermal camera for heat measurement | InfiRay P2 Pro or Topdon TC001 class | 1 | $200–300 | Amazon |
| B24 | Fine soldering iron, hot-air station, microscope, USB-UART adapter, calipers | | 1 set | $300–800 | Amazon, Digi-Key |
| B25 | Linux build machine for Android (16+ cores, 64 GB RAM, 1 TB SSD), or a cloud instance | | 1 | $0–2,500 | |
| | **Parts for one pair (B1, B4–B21)** | | | **about $1.5k–3.5k** | |
| | **Parts for three pairs with spares** | | | **about $4k–8k** | |
| | **Plus ODM BSP and support (B2–B3), tools (B22–B25)** | | | **about $1k–14k** | |
| | **Route B total** | | | **about $8k–25k** including a mechanical designer for a few weeks | |

The ODM board already carries the GNSS, magnetometer, barometer, IMU, light and proximity sensors, charger and fuel gauge from the eeworld spec, so route B needs no separate sensor parts. If the board you buy lacks one, use a breakout to test: Memsic **MMC5603NJ** or Bosch **BMM350** (magnetometer), Bosch **BMP585** (barometer), u-blox **MIA-M10Q** (GNSS, UART).

**Battery reality check.** Off-the-shelf cells that fit the 46 × 10 × 6 mm space in the [packaging plan](glasses-packaging.md) hold about 200–300 mAh (0.75–1.1 Wh) each, not the 350–400 mAh assumed in the board doc. The POC will run on stock cells; the production target needs a custom high-density cell (ATL, Sunwoda, Grepow), which takes 3–6 months of tooling.

### Route C: Qualcomm reference POC

| # | Part | Example | Price | Where |
| --- | --- | --- | --- | --- |
| C1 | Snapdragon AR1+ Gen 1 or XR2 Gen 2 reference hardware with BSP | Qualcomm reference design through a design house | $5k–30k hardware, plus NRE and NDA | Qualcomm, Thundercomm, Goertek, Lantronix |
| C2 | Full-color microLED projector evaluation kit | JBD Hummingbird-series projector dev kit | $5k–20k | JBD (Shanghai) |
| C3 | Waveguide evaluation kit | Lumus, DigiLens, Vuzix, Dispelix | $5k–30k | the waveguide maker |
| C4 | Design-house engineering (board adaptation, Android bring-up) | | $20k–60k | Thundercomm or similar |
| C5 | Frame, batteries, cameras, tools as route B | | $5k–10k | as route B |
| | **Route C total** | | **about $50k–150k** | |

Qualcomm does not sell these chips or kits through retail distributors; access starts with a sales contact and NDA, usually through a design house.

## 3. Production parts list (the custom board)

The parts the EVT board would use, filling in the [board design](glasses-board.md). The SoC, PMIC, memory, storage and modem come from the chosen Qualcomm reference design's validated list; their exact part numbers are under NDA.

| Block | Part | Interface | Rail | Notes |
| --- | --- | --- | --- | --- |
| SoC | Snapdragon XR2 Gen 2 or AR1+ Gen 1 | — | PMIC rails | decided at the end of the POC |
| PMIC | Qualcomm PM-series set matched to the SoC | SPMI | VBAT | from the reference design |
| Memory | LPDDR5X PoP, 8 or 16 GB | on package | PMIC | Qualcomm-validated Micron, Samsung or SK hynix part |
| Storage | UFS 4.0, 128–256 GB | UFS 2-lane | 2.5 V / 1.2 V | validated list |
| Modem (5G version) | Snapdragon X75-class + matched RF front end | PCIe Gen 3 | PMIC | skip for the phone-paired version |
| Wi-Fi 7 + BT 5.4 | Qualcomm FastConnect 7800 | PCIe + UART | PMIC | |
| GNSS | SoC's own GNSS engine + Infineon **BGA524N6** LNA, L1/L5 antenna | RF | 1.8 V | u-blox MIA-M10Q over UART if the SoC lacks GNSS |
| IMU | ST **LSM6DSV16X** or Bosch **BMI270** | I3C/I2C + 2 interrupts | 1.8 V | on the main board, near the hinge |
| Magnetometer | Memsic **MMC5603NJ** or Bosch **BMM350** | I2C | 1.8 V | keep 10 mm or more from speaker magnets and the battery |
| Barometer | Bosch **BMP585** | I2C/I3C | 1.8 V | needs a vent hole with a waterproof membrane |
| Light + proximity (wear) | ams **TMD2635** or Vishay **VCNL4040** | I2C + interrupt | 1.8 V / 3.3 V | proximity faces the temple |
| Touchpad controller | Azoteq **IQS7211E** | I2C + RDY interrupt | 1.8–3.3 V | sensor pattern on the outer arm flex |
| Audio codec | the SoC vendor's SoundWire codec (WCD938x class) | SoundWire | PMIC | from the reference design |
| Speaker amps | Cirrus **CS35L41** or the reference design's smart amp | SoundWire/I2S + I2C | VBAT | |
| Microphones | 3 × Infineon **IM69D130** | PDM | 1.8 V | two front for beam-forming, one near the mouth |
| Cameras | Sony **IMX681** 12 MP (4-lane CSI) and OmniVision **OV9282** (1–2 lane CSI) | MIPI CSI-2 + I2C (CCI) | 2.8 / 1.8 / 1.1 V | see [camera doc](glasses-camera.md) |
| Privacy LED | white LED fed from the camera rail through TI **TPS22916** | — | camera rail | hardware rule, no software control |
| Displays | JBD microLED projector per eye, with its driver | MIPI DSI, one link per eye | per panel datasheet | micro-OLED (Sony ECX343EN) is the fallback |
| Charger | TI **BQ25620** (I2C, up to 3.5 A) or the reference design's charger | I2C + interrupt | VBUS 5–9 V | set to 1.4 A for the 50% in 15 min target |
| Fuel gauge | TI **BQ27427** | I2C | VBAT | one per pack, cells in parallel |
| Cell protection | TI **BQ2970** family | — | per cell | one per cell |
| Buttons | 4 × C&K **KMR2** | GPIO, power key to PMIC | 1.8 V | power, shutter, volume up and down |
| Fold / case sensor | TI **DRV5032** | GPIO interrupt | 1.8 V | |
| Thermistors | 2–4 × Murata **NCP03XH103** | PMIC ADC | — | skin side of each arm, SoC, battery |
| Antennas | Ignion or Taoglas chip antennas, or custom LDS in the frame | coax / matching | — | 5G, Wi-Fi/BT, GNSS |

## 4. Connections (schematic starting point)

### Buses

| Bus | Devices | Notes |
| --- | --- | --- |
| I3C/I2C bus 1, 1.8 V (sensors) | IMU (0x6A/0x6B), magnetometer (MMC5603 0x30), barometer (BMP585 0x46/0x47), light + proximity (TMD2635 0x39 or VCNL4040 0x60) | on the SoC's low-power sensor island so sensors run while the CPU sleeps; check each address in its datasheet |
| I2C bus 2, 1.8 V (input) | touchpad controller (IQS7211E 0x56) | RDY interrupt to a wake-capable GPIO |
| I2C bus 3, 1.8 V (power) | charger (BQ25620 0x6B), fuel gauge (BQ27427 0x55) | separate bus, so a stuck sensor cannot block charging |
| CCI (camera I2C) | IMX681, OV9282 | the SoC's dedicated camera control buses |
| MIPI CSI-2 | CSI0 4-lane: IMX681 (right hinge flex); CSI1 1–2 lanes: OV9282 (frame flex) | 2 spare lanes on the frame flex for eye tracking later |
| MIPI DSI | DSI0: right display; DSI1: left display (frame flex) | 4-lane each, impedance-controlled 100 Ω pairs |
| SoundWire | codec, speaker amps | |
| PDM | 3 microphones | |
| PCIe | modem (5G version), Wi-Fi | |
| UART | Bluetooth; debug console on test pads; GNSS module if discrete | |
| USB 2.0 | pogo pins (data for flashing and adb) | the pogo connector carries VBUS, GND, D+, D− |
| SPMI | PMIC(s) | |

### GPIOs and interrupts

| Signal | From | To | Notes |
| --- | --- | --- | --- |
| PWR_KEY | power button | PMIC power key input | long press on and off; very long press = hard reset |
| CAM_KEY, VOL_UP, VOL_DN | buttons | SoC GPIOs with pull-ups | handled as Android key events |
| IMU_INT1, IMU_INT2 | IMU | sensor-island GPIOs | wake on motion, tap |
| PROX_INT | proximity sensor | GPIO | on-head detection |
| TP_RDY | touchpad controller | GPIO | |
| HALL_INT | DRV5032 | GPIO | folded / in case |
| CHG_INT | charger | GPIO | |
| CAM_PWR_EN | SoC GPIO | TPS22916 enable | the LED is wired to the switched output |
| LED_SENSE | photodiode beside the LED | SoC ADC | covered-LED check |
| CAM_RST, TRK_RST | SoC GPIOs | camera reset pins | |
| DISP_RST_L, DISP_RST_R | SoC GPIOs | display reset pins | |

### Power rails

| Rail | Source | Feeds |
| --- | --- | --- |
| VBUS 5–9 V | pogo pins | charger only |
| VBAT 3.0–4.4 V | two cells in parallel, each with its protection IC | charger output, PMIC, speaker amps, display boost |
| 1.8 V IO | PMIC | sensors, touch, buttons, IO |
| SoC, memory and modem rails | PMIC set | as the reference design |
| Camera rails 2.8 / 1.8 / 1.1 V | PMIC LDOs through TPS22916 | IMX681 and the privacy LED |
| Display rails | PMIC or a small boost per panel | per panel datasheet |

## 5. Mechanical sizes

| Item | Size | Source |
| --- | --- | --- |
| Front frame width | 140 mm | [packaging plan](glasses-packaging.md) |
| Arm length, height at the hinge, thickness | 145 mm, 16 mm, 6–7 mm | packaging plan |
| Main board (right arm) | 60 × 13 mm, both sides, 0.8 mm 10–12 layer HDI | packaging plan |
| Radio board (left arm) | 60 × 13 mm | packaging plan |
| ODM POC board (route B) | about 55 × 16 × 3.8 mm; the arm grows to about 19 mm tall at the hinge for the POC | eeworld-class board |
| Battery space per arm | 46 × 10 × 6 mm | packaging plan |
| Projector per end piece | about 6 × 6 × 10 mm (microLED); about 12 × 10 × 8 mm for a 0.39 in micro-OLED with birdbath, so the POC end pieces are bigger | |
| RGB camera module | about 7 × 7 × 5 mm; end piece at least 9 mm tall | [camera doc](glasses-camera.md) |
| Tracking camera | about 5 × 5 × 4 mm | camera doc |
| Touchpad | about 55 × 12 mm, outer face of the right arm | packaging plan |
| Buttons | power on the underside of the right arm near the hinge; camera shutter on top of the right arm; volume on top of the left arm | this doc |
| GNSS antenna | top of the left arm, facing the sky, away from the battery | this doc |
| Barometer vent | 0.5 mm hole under the left arm with a waterproof membrane | this doc |
| Magnetometer | left arm, at least 10 mm from the speaker and battery | this doc |
| Pogo pins | underside of the right arm, 2–4 pins at 2.5 mm pitch | packaging plan |
| Target weight | POC 80–100 g; product 65–85 g | packaging plan |

Start the CAD in any tool (Fusion, Onshape, SolidWorks) from these numbers, with the real board, panel and cell outlines from the ODM's drawings dropped in. Print the first frame within two weeks of the board arriving.

## 6. OS and apps: how to start building

### Which OS on which route

| Route | OS | Where it comes from |
| --- | --- | --- |
| A | the phone's or board's own Android 14+; our launcher runs as an app on the glasses' screen (second display) | nothing to build |
| B | Android 13+ from the ODM's BSP (MediaTek kernel and drivers), with our launcher as the home app | the ODM's source tree |
| C and product | AOSP on Qualcomm's BSP, our launcher and system UI; Android XR if Google accepts us ([software plan](glasses-software-platform.md#which-android)) | Qualcomm through the ODM or design house |

### Bring-up on the ODM board (route B)

1. **Get the source.** Ask the ODM for the full BSP: kernel source, device tree, vendor HALs, the AOSP manifest and a build guide. A board you cannot rebuild is a dead end, so make this a condition of the sample order.
2. **Set up the build machine.** Ubuntu LTS, 64 GB RAM, about 400 GB per tree. `repo init` with the ODM's manifest, `repo sync`, then `source build/envsetup.sh`, `lunch <ODM target>`, `m`. Flash with the vendor's tool (MediaTek SP Flash Tool) or `fastboot`.
3. **Boot and console.** Confirm the UART console and `adb` over the pogo-pin USB before touching anything else.
4. **Displays.** The ODM normally ships a driver for the ECX343 or SY049 panels; check both eyes show, then set a fixed landscape density so apps lay out for a small window.
5. **Input.** Map the touchpad controller to Android key events (swipe = DPAD left/right/up/down, tap = DPAD_CENTER, two-finger tap = BACK), and the buttons to POWER, CAMERA, VOLUME_UP, VOLUME_DOWN in the key layout file.
6. **Cameras.** Bring up the 13 MP sensor through the vendor camera HAL, then the tracking camera; wire the privacy LED to the camera rail and check it lights on every capture.
7. **Sensors and GPS.** Check the IMU, magnetometer, barometer, light, proximity and GNSS through the vendor sensor HAL with a sensor test app and a GPS test app outdoors.
8. **Power.** Calibrate the fuel gauge for the cells you bought; set the charger to 1.4 A for the fast-charge test; set thermal limits from the arm thermistors.
9. **Our layer.** Install the Aurora launcher as the default home app, the glasses dark theme, and the first launch apps. Build them into the system image once they are stable.
10. **Measure.** Battery life and arm temperature for each launch-app scenario with the PPK2 and thermal camera. These numbers decide the production SoC and battery.

### The apps

The order to build the ten [launch apps](glasses-software-platform.md#launch-apps), so each step is useful on its own:

| Step | Apps | Needs |
| --- | --- | --- |
| 1 | **Aurora launcher** (home cards, touchpad focus navigation, dark see-through theme) | route A hardware; the [starter project](../apps/aurora-launcher/README.md) in this repo |
| 2 | Notifications, Teleprompter and notes | launcher |
| 3 | Camera with the privacy-LED rule | route B board |
| 4 | Aurora Assistant (voice + "what am I looking at?") | camera, a cloud AI API, on-device wake word |
| 5 | Live captions and translation | microphones, speech model |
| 6 | Navigation | GNSS, magnetometer, a maps SDK (Mapbox or HERE) |
| 7 | Calls, music, visual description, remote assist | the above |
| 8 | Companion phone app with the Aurora Store | Android first, iOS later |

The [starter launcher](../apps/aurora-launcher/README.md) is a plain Android app (Kotlin, Jetpack Compose) with the glasses rules built in: black background (transparent on the lenses), large bright text, cards you move between with a touchpad or arrow keys, and a 640 × 480 landscape layout. It runs on the Android emulator, on a phone sending a second screen to display glasses (route A), and on the ODM board (route B).

## 7. Build plan

| Phase | Weeks | What you do | Exit test |
| --- | --- | --- | --- |
| 0. Start | 0–2 | Order route A parts; open the starter launcher in Android Studio; send RFQs (requests for quote) to 3–5 Shenzhen AR-board ODMs asking for board, BSP source, schematic, panels and optics | launcher on the display glasses; at least two ODM quotes |
| 1. Apps on route A | 2–8 | Launcher, notifications, notes, assistant using the phone's camera | five people can use the launcher with a touchpad without help |
| 2. Route B parts | 2–10 | Buy 2–3 ODM boards with panels, optics, cameras, cells; build the ODM's BSP yourself; bring up on the bench (steps 1–8 above) | both eyes, camera, sensors and GPS working on the bench |
| 3. Frame | 6–12 | CAD the POC frame from section 5 around the real parts; print three iterations; make the hinge flex | the pair fits and folds; weight under 100 g |
| 4. Wearable POC | 10–16 | Assemble 1–3 pairs; move the apps across; measure battery life, heat and weight | a demo video of the apps on the head; measured hours of use and arm temperature |
| 5. Decide | 16–18 | Use the measurements to answer the [open questions](glasses-board.md#open-questions); approach Qualcomm design houses (route C) and investors with the POC | SoC, 5G or phone-paired, memory size and battery decided |

Things to ask every ODM in the first message: board size, SoC, RAM and storage options, which displays and cameras the BSP already supports, whether the full BSP source and schematic come with the sample, sample price and lead time, minimum order for later volume, and whether they can make the optics and frame too.

## What only you can decide or do

- Pick route A, B or both, and the budget for the POC.
- Approve the ODM and sign their sample order and any NDA.
- Hire or contract the Android/BSP engineer and the mechanical designer for phase 2–4.
- Open the Qualcomm and Google Android XR conversations when the POC works.
