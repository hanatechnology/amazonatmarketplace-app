---
name: run-marketplace-app
description: Launch the Amazonat Flutter app on the iOS simulator and screenshot a specific screen, in either language and either theme. Use when asked to run the app, verify a change in the real app, capture Arabic RTL or dark-mode boards, or reproduce a UI bug that analyze cannot see.
---

# Running the Amazonat mobile app

Verified end to end on 2026-08-28 against the local backend, iPhone 16 simulator,
iOS 18.0. Every command below was actually executed; the pitfalls section
records failures that really happened, not hypotheticals.

---

## 0 — Preconditions

**Flutter is not on `PATH`.** The project uses fvm:

```bash
FLUTTER=/usr/local/bin/fvm\ flutter   # i.e. always `fvm flutter …`
/usr/local/bin/fvm flutter devices
```

**The backend must be running.** Almost every screen is bearer-gated and will
render error/empty states without it:

```bash
curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 \
  http://localhost:3003/client/api/v1/health     # expect 200
```

If nothing is listening on 3003, say so and stop — screenshots of a dead
backend prove nothing.

**Constants**

| Thing | Value |
|---|---|
| Bundle id | `com.hanatech.marketplace` |
| Simulator | iPhone 16, get the UDID from `fvm flutter devices` |
| API base | `http://localhost:3003/client/api/v1` |

---

## 1 — Boot the simulator and set the OS appearance

```bash
UDID=$(/usr/local/bin/fvm flutter devices 2>/dev/null \
  | grep -i 'iPhone .*simulator' | head -1 | awk -F'•' '{print $2}' | tr -d ' ')
xcrun simctl bootstatus "$UDID" -b
open -a Simulator
xcrun simctl ui "$UDID" appearance dark     # or light
```

`appearance` only matters when the app's own theme mode is `system`. The app
stores its own preference — see next step.

---

## 2 — Force language and theme (the app ignores the system locale)

`main.dart` hardcodes `locale: const Locale('en','US')`. The only things that
change language are `LocaleController`'s stored preference and the in-app
toggle. Same for theme via `ThemeService`. Seed both in the app's preference
plist, then relaunch:

```bash
BID=com.hanatech.marketplace
CONTAINER=$(xcrun simctl get_app_container "$UDID" "$BID" data)
PLIST="$CONTAINER/Library/Preferences/$BID.plist"

/usr/libexec/PlistBuddy -c "Add :flutter.app_locale string ar_SA" "$PLIST" \
  || /usr/libexec/PlistBuddy -c "Set :flutter.app_locale ar_SA" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :flutter.app_theme_mode dark" "$PLIST"

xcrun simctl launch "$UDID" "$BID"
```

- `flutter.app_locale` — `ar_SA` or `en_US` (SharedPreferences prefixes every
  key with `flutter.`).
- `flutter.app_theme_mode` — `light`, `dark`, or `system`.
- The app must be **installed** before the container exists. Run it once first.
- The JWT lives in the keychain, not this plist, so a signed-in session
  survives reinstalls. `flutter.auth_user` here is only the cached profile.

**Leave a note in your report if you change these** — they persist, and the
next person's screenshots will silently be in the language you left behind.

---

## 3 — Open a specific screen

`flutter run --route=…` **does nothing** in this app: `GetMaterialApp` sets
`initialRoute: Routes.MARKETPLACE`, which wins. There is no tap driver
available either (`idb` is not installed, and AppleScript against the
Simulator window blocks on an accessibility grant that cannot be approved
from here).

So: temporarily repoint `initialRoute`, and **restore it afterwards**.

```bash
cp lib/main.dart /tmp/main.dart.bak          # always back up first

shoot () {   # shoot <route> <output-name>
  sed -i '' "s|initialRoute: .*,|initialRoute: '$1',|" lib/main.dart
  xcrun simctl terminate "$UDID" "$BID" 2>/dev/null
  pkill -f "flutter run" 2>/dev/null; sleep 2
  nohup /usr/local/bin/fvm flutter run -d "$UDID" --debug > "/tmp/r_$2.log" 2>&1 &
  for i in $(seq 1 45); do sleep 3; grep -q "Dart VM Service" "/tmp/r_$2.log" && break; done
  sleep 9                                    # let the first fetch land
  xcrun simctl io "$UDID" screenshot "/tmp/$2.png"
  pkill -f "flutter run" 2>/dev/null; sleep 2
}

shoot /marketplace/search        search
shoot /marketplace/addresses     addresses

cp /tmp/main.dart.bak lib/main.dart          # NON-NEGOTIABLE
git diff lib/main.dart                       # confirm it is clean
```

**Routes reachable this way** (no `Get.arguments` needed): `/marketplace/search`,
`/marketplace/products-list`, `/marketplace/addresses`, `/marketplace/add-address`,
`/marketplace/orders`, `/marketplace/login`, `/marketplace/join`,
`/marketplace/onboarding`, `/marketplace/refund-request` only with an order.

**Not reachable this way:** anything reading `Get.arguments` — product detail
(needs an id), checkout (`CheckoutArgs`), refund request (`OrderEntity`) — and
anything that is a *tab* rather than a route: Categories and Account live
inside `MainNavigationPage`. Reaching those needs real taps. Say so rather
than faking it.

---

## 4 — Read the app's own logs

`nohup … > log` **loses Dart `print` output**. To see the `DioClient` request
and response dumps, tee a foreground run instead:

```bash
( /usr/local/bin/fvm flutter run -d "$UDID" --debug 2>&1 | tee /tmp/probe.log ) &
for i in $(seq 1 50); do sleep 3; grep -aq "DioClient" /tmp/probe.log && break; done
grep -a "uri:\|statusCode:\|Accept-Language" /tmp/probe.log | head -40
```

`xcrun simctl spawn … log show` does **not** surface Flutter `print` output —
do not waste time on it.

To answer a question about runtime state (what `Directionality` resolves to,
what a controller holds), add a temporary `print` to the widget's `build`,
run with the tee above, grep for it, then delete the probe. That is how the
RTL chevron bug was pinned down instead of guessed.

---

## 5 — Pitfalls that cost real time

- **Killing `flutter run` does not kill the app.** The old instance stays on
  screen and the next screenshot shows the *previous* route. Always
  `xcrun simctl terminate "$UDID" "$BID"` before relaunching, and sanity-check
  that the screenshot is the screen you asked for.
- **Deep-linked routes need self-registering bindings.** Repositories are
  registered by `MainNavigationBinding`; a route entered directly throws on
  `Get.find<SomeRepository>()` and the screen renders half-empty. The product,
  search, products-list, category and address bindings now guard with
  `if (!Get.isRegistered<T>())`. If a newly deep-linked screen comes up blank,
  suspect this first.
- **Material chevrons auto-mirror under RTL.** `Icons.chevron_left_rounded`
  already flips itself when `Directionality` is RTL. Do *not* add an
  `isRtl ? … : …` ternary — that double-flips and points the arrow backwards
  in Arabic. Use the LTR-semantic icon and let the framework mirror it.
- **Nested `TextField`s inherit the global `InputDecorationTheme`**, which sets
  `filled: true` plus `enabledBorder`/`focusedBorder`. A field inside one of our
  own decorated containers then draws a second box. `border: InputBorder.none`
  alone does not fix it — set `filled: false` and *all* the border slots.
- `Target native_assets required define SdkRoot but it was not provided`
  appears on every build. It is noise; the build succeeds.
- The maps SDK key is absent by default, so `location_picker_page` renders a
  grey tile grid rather than a map. That is expected, not a crash.

---

## 6 — What to report

Screenshots alone are not a result. For each captured screen say what the live
data proved: which endpoint answered, whether the RTL/mirroring is right,
whether currency and digits render Latin and trailing, and anything that looks
wrong. A blank or unexpected screen is a failure to launch — investigate it
before reporting success.
