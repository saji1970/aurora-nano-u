# Aurora glasses: Android OS and apps

This is the plan for the software on the Aurora glasses: which Android to run, what has to change for a see-through display in each lens and a touchpad instead of a touch screen, how apps get onto the glasses, which apps should be there on day one, and what it costs in people and money. It sits on top of the [main-board design](glasses-board.md) (Qualcomm XR2 Gen 2-class SoC, 16 GB, 256 GB) and the new [camera system](glasses-camera.md).

All costs are planning estimates. They are already added to the [cost estimate](glasses-cost-and-sourcing.md) and the [funding requirement](glasses-funding-requirement.md).

## The short version

- **Run Android (AOSP) on Qualcomm's board support package**, with our own glasses launcher and system UI. This needs nobody's permission and works on any Qualcomm glasses chip.
- **Apply to Google's Android XR program in parallel.** If accepted, the same hardware gets Google Play, Gemini and Google Maps with much less of our own app work. If not, the glasses still ship.
- **Three kinds of apps:** glasses-native apps built with our SDK, ordinary Android phone apps in a floating window, and apps that run on the phone and show cards on the glasses.
- **Our own curated store at launch**, plus a companion phone app that installs and manages apps. Google Play only arrives with Android XR or a Google services licence.
- **Ten launch apps**, led by the camera, an AI assistant that can see what you see, live captions and translation, navigation and notifications.
- **The software adds about $1.3M to the funding plan** on top of the Android team already budgeted, mainly two more engineers, the store and SDK, and launch-app licences.

## Which Android

| Option | What it is | For us | Against us |
| --- | --- | --- | --- |
| **AOSP on Qualcomm's BSP** (recommended base) | open-source Android, with Qualcomm's drivers for the SoC, GPU, ISP, modem and power management, normally delivered through the ODM or a design house such as Thundercomm | available to any company with Qualcomm access; full control of the UI; no Google approval; the route most glasses makers outside Google's program take | no Google Play, Gmail, Maps or Gemini; we build or license the store, maps, speech and assistant ourselves |
| **Android XR** (pursue in parallel) | Google's version of Android for headsets and glasses, announced in December 2024, shipping on Samsung's Galaxy XR headset since October 2025, with glasses partners announced | Google Play, Gemini and Google's apps already adapted for glasses; developers already targeting it; a big boost to credibility | access is by partnership with Google, not open to every device maker; Google sets the UI and its rules; timing is not in our control |
| **AOSP + Google Mobile Services licence** | ordinary Android with Play, as on phones | Play Store with millions of apps | Google licenses GMS for phones and tablets; glasses are outside the normal programme, and passing the compatibility tests on a 640-pixel see-through display is unlikely |
| **A non-Android OS** (Linux, an RTOS, or our own) | what some light camera-and-audio glasses use | lowest power | throws away the whole Android app world, which is the reason to build standalone glasses |

So the base is AOSP with the BSP, designed so that switching to Android XR later changes the system image and launcher, not the hardware or our own apps. Google moved AOSP development to an internal branch in 2025 and now publishes the source in periodic drops; that does not affect a device maker shipping on Qualcomm's BSP, but it means our releases follow Google's publishing schedule.

**Android version and support window.** Ship on the newest Android release that Qualcomm's BSP for the chosen SoC supports at the start of EVT, and plan for at least 4 years of monthly security patches and 2–3 major upgrades. That support window has to be written into the Qualcomm and ODM contracts, because BSP updates come from them.

## What changes for glasses

### The display

| Phone assumption | On Aurora | What we change |
| --- | --- | --- |
| a 6-inch, 1080 × 2400 opaque screen | a see-through microLED image of about 640 × 480 to 1280 × 720 per eye, about 30° wide, floating about 1–2 m in front | a fixed virtual display size and density in the display configuration, so apps lay out for a small landscape window |
| black is black | black is **transparent**: the projector only adds light | a system dark theme with bright text on black; white areas are avoided because they block the view and burn power |
| the screen is always on while in use | the display is off most of the time | glanceable cards that appear for seconds, then fade; an always-off default to save the battery |
| one screen | two eyes | the same 2D image to both eyes for apps; stereo rendering only for 3D apps through OpenXR |

The compositor (SurfaceFlinger with Qualcomm's display driver) gets a glasses mode: both MIPI DSI outputs driven from one 2D layer stack, per-eye calibration for the waveguide's colour and brightness, automatic brightness from the ambient-light sensor, and image shifting to keep text steady as the head moves slightly.

### Input

There is no touch screen, so every interaction goes through one of these:

| Input | How it maps into Android |
| --- | --- |
| **Temple touchpad** (the main one) | swipe forward/back moves focus between items, tap selects, two-finger tap goes back, swipe down goes home; it uses Android's focus navigation, the same system Android TV uses with a remote, so apps built for keyboards and TV already mostly work |
| **Voice** | "Hey Aurora" wake word on the SoC's low-power audio DSP; commands to open apps, take photos, ask questions, dictate replies |
| **Phone as a trackpad and keyboard** | the companion app turns the phone screen into a touchpad and keyboard for typing passwords and long text |
| **Hand tracking** (with the [tracking camera](glasses-camera.md)) | pinch to select, point to aim, open-hand swipe; delivered through OpenXR's hand-tracking extension and mapped to focus and select for 2D apps |
| **Head gestures** (from the IMU) | nod to accept a call, shake to dismiss |

### Power and heat in software

The [power budget](glasses-board.md#the-power-budget-is-the-main-risk) is the hardest limit, so the OS enforces it:

- Apps get a low default CPU and GPU budget; a short boost is granted on user action.
- Background apps are frozen aggressively, more than on phones.
- 5G is off unless no phone or Wi-Fi is near; data goes through the phone over Bluetooth or Wi-Fi Direct by default.
- The thermal service reads the arm sensors and caps video length, brightness and frame rate before the frame feels warm.
- The camera service enforces the [privacy LED](glasses-camera.md#privacy-led-a-hardware-rule-not-a-setting) rules and the clip limits.

## How apps get onto the glasses

| Tier | What it is | Example | Built with |
| --- | --- | --- | --- |
| **1. Glasses-native apps** | apps designed for the glasses: cards, a minimal focus-driven UI, voice, camera and AI | the launch apps below; third-party apps from our store | Android + Jetpack Compose with our **Aurora SDK**: a glasses theme, card and list components, touchpad and voice input helpers, camera and AI-assistant APIs, and an emulator profile for Android Studio |
| **2. Ordinary Android apps** | unmodified Android phone apps shown in a floating window, controlled with the touchpad focus or the phone as a trackpad | music players, podcasts, messaging, note apps | nothing new; we test the top apps and mark the ones that work well |
| **3. Phone-driven apps** | apps that stay on the phone and send cards, notifications or a mirrored screen to the glasses | notifications from any phone app, a phone's navigation, a video call | the companion app, plus a small SDK so phone apps can push their own cards |
| (3D apps) | full 3D, head-tracked apps | games, 3D models, spatial video | OpenXR on Qualcomm's runtime; Unity and Unreal can target it. Narrow field of view limits these, so they are not a launch focus |

Tier 1 is what makes Aurora feel designed; tier 2 makes the app count large from day one; tier 3 keeps the battery and heat low because the phone does the heavy work.

### Store strategy

| Phase | How apps get onto the glasses |
| --- | --- |
| Launch | **Aurora Store** inside the companion phone app: a curated catalogue of glasses-native apps plus a "works well on Aurora" list of ordinary Android apps. Developers submit APKs through a web developer console; we review them for glasses fit and privacy, especially camera use. Developer mode allows sideloading over USB or Wi-Fi |
| Alongside | Open-source apps from **F-Droid** can be installed in developer mode; enterprise customers install their own apps through Android Enterprise device management |
| If Android XR is approved | **Google Play** replaces most of the store's job; the Aurora Store stays for glasses-specific apps and enterprise |

Revenue share would follow the industry norm (15% on a developer's first $1M a year, then 30%), but it will be close to nothing for the first two years. The store is there to make apps easy to find and to keep camera apps honest, not to earn money early. A small developer fund ($100k in the plan) pays the first 10–15 outside developers to port their apps.

## Launch apps

| App | What it does | Built or licensed |
| --- | --- | --- |
| **Camera** | photo and up to 3-minute video from your point of view, with the privacy LED; syncs to the phone's gallery | built, on the camera ISP pipeline |
| **Aurora Assistant** | voice assistant that can see what you see: "what is this plant?", "read this sign", "remind me where I parked", summaries of notifications. Runs a small model on the SoC's AI engine for quick answers and wake-word, and a cloud model for harder questions | built on a licensed cloud model API and an on-device open-weight model; the later Aurora-Nano chip would take over the on-device part |
| **Live captions and translation** | subtitles of what people around you say, and translated subtitles; uses the microphones and on-device speech recognition | built on licensed or open speech models |
| **Navigation** | walking and cycling turn-by-turn arrows in view; no need to look at a phone | licensed maps and routing (Mapbox or HERE; Google Maps needs Google services) |
| **Notifications and messages** | phone notifications as glanceable cards; voice replies | built (companion app) |
| **Calls and video calls** | voice calls through the glasses; video calls that show what you see | built on standard Android telephony plus WebRTC; works with ordinary calling apps through tier 2 |
| **Music and podcasts** | open-ear audio with simple controls | tier 2 apps (Spotify, YouTube Music and others where they run without Google services) plus a simple built-in player |
| **Teleprompter and notes** | your speaker notes in view; quick voice notes | built |
| **Visual description (accessibility)** | for blind and low-vision users: describes scenes, reads text and recognises banknotes aloud | built on the assistant |
| **Remote assist (business)** | a remote expert sees your camera and marks up your view; checklists hands-free | built, or a partner such as TeamViewer or Microsoft Teams-based tools through tier 2 |

Accessibility and business apps are where standalone display glasses already sell, so they double as the first target customers named in the [funding plan](glasses-funding-requirement.md#risks-and-how-this-plan-handles-them).

## Privacy and security

- Camera, microphone and location use Android's permission system, plus a glasses rule: an app can only use the camera while it is in front, and the privacy LED is always lit by hardware.
- The store rejects apps that record without a visible user action or upload camera frames without disclosure.
- Face recognition of strangers is not allowed in the store and not offered by the assistant.
- Verified boot, file-based encryption and A/B system updates, as on phones; monthly security patches for at least 4 years.
- AI requests that leave the glasses are encrypted, not stored after the answer, and not used for training unless the user opts in.

## The companion phone app

Android and iOS. It pairs the glasses, installs and updates apps (the store lives here), syncs photos and videos, forwards notifications, shares the phone's internet, acts as a trackpad and keyboard, and sets privacy and business policies. iOS restricts what a companion app can do in the background (notifications from other apps arrive only through Apple's Bluetooth notification service), so the iPhone experience will be narrower than Android's at launch.

## Team and schedule

The [funding plan](glasses-funding-requirement.md#team-and-hiring-plan) already budgets Android platform and driver engineers (1 → 3 → 4) and app and AI engineers (0 → 2 → 3). This plan adds two people in the Series A: a camera and imaging engineer, and a developer-platform engineer for the SDK, store and developer relations.

| Stage | Software milestone |
| --- | --- |
| Pre-seed (months 0–6) | AOSP running on the Qualcomm development kit driving the evaluation display; touchpad focus navigation; first camera capture; measured power for each launch-app scenario; Android XR application sent to Google |
| Seed (months 6–15) | bring-up on the custom EVT boards; glasses launcher and system UI; camera tuned; first versions of Camera, Assistant, Captions, Notifications; companion app for Android; pilot users on EVT |
| Series A (months 15–30) | all ten launch apps; Aurora SDK and developer console public 6 months before launch; Aurora Store live; iOS companion app; security and privacy audit; OTA update system and 4-year patch plan in place |

The total software effort is about 60–90 engineer-years over the 30 months, inside the team already planned plus the two new hires and contractors for the store backend and launch-app licences.

## What it costs

### One-time

| Item | Low | High | In the plan |
| --- | --- | --- | --- |
| Android bring-up, drivers, launcher, power and thermal tuning, OTA (the original software line) | $1.0M | $3.0M | already in the team budget |
| Aurora Store, developer console, SDK and docs, companion-app store | $200k | $400k | **$300k, Series A** |
| Launch-app licences and services set-up: maps, speech, translation, cloud AI; developer fund | $150k | $350k | **$250k, Series A** |
| Two more engineers (camera and imaging; developer platform) for 15 months | $450k | $600k | **$510k, Series A** |
| Development kits, Android XR programme engagement, software tools | $30k | $80k | **$50k, seed** |
| Camera image-quality tuning (see the [camera doc](glasses-camera.md#cost)) | $120k | $300k | **$150k, seed** |
| Camera factory test fixtures | $30k | $100k | **$50k, Series A** |

The cost estimate's software line grows from $1.0–3.0M to **$1.3–3.6M** with the store, SDK and launch apps; the camera tuning and fixtures are a separate new line there.

### Running costs after launch

| Item | Rough cost |
| --- | --- |
| Cloud AI for the assistant and visual questions | about $0.50–2 per active user a month, depending on how much runs on the glasses |
| Maps, speech and translation services | about $0.20–1 per active user a month at low volume |
| Store hosting, crash reporting, OTA delivery | about $2–5k a month at launch scale |
| Security patches and Android upgrades | inside the platform team's running cost |

At 5,000 users that is about $4–15k a month, small next to the team. A paid tier for heavy AI and translation use (for example $5–10 a month) would cover it as the user base grows.

## Risks

| Risk | What we do |
| --- | --- |
| Google does not accept Aurora into Android XR, so no Play Store | AOSP-based plan is the base case, not the fallback; the store, maps and assistant are budgeted without Google |
| Ordinary Android apps work badly with a touchpad and a small display | test the top 200 apps and list only those that work; push developers toward the SDK; the phone-as-trackpad covers the rest |
| Qualcomm or the ODM stops BSP updates early | write a 4-year update commitment into both contracts before EVT |
| AI and camera features drain the battery | on-demand capture, clip limits, the phone does heavy work, and the power measurement milestone at pre-seed |
| Camera privacy backlash | hardware LED, covered-LED check, no stranger face recognition, store review rules, business camera-off policy |

## Next steps

- [ ] Get Qualcomm's BSP and the development kit through the ODM or Thundercomm; bring up AOSP on it with the evaluation display.
- [ ] Contact Google's Android XR partner team with the product concept.
- [ ] Prototype the touchpad focus navigation and dark see-through theme on the dev kit and test them with five people.
- [ ] Pick the cloud AI model provider, speech models and maps provider; get price quotes.
- [ ] Draft the store review rules for camera and microphone apps.
