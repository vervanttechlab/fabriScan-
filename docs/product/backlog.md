# FabriSCAN+ — Product Backlog

Version 0.1 · 2026-11-16 · Priorities use MoSCoW (Must / Should / Could / Won't for now). Feature IDs (F1, F2, …) refer to `PRD.md` §4.

---

## Epic E1 — Onboarding & access (F7, F8)

**US-01 First-launch onboarding** · Must · F8
As a first-time user, I want a short intro so that I know the app can scan fabric and give care tips.
- Given a fresh install, When I open the app, Then I see a 3-screen intro with **Skip** on every screen.
- Given I finished or skipped the intro, When I open the app again, Then I don't see it again.

**US-02 Continue as guest** · Must · F7, R5
As a guest, I want to use every core feature without an account so that I can check a garment quickly.
- Given I'm on the access screen, When I tap **Continue as Guest**, Then I reach Home, and Scan, Upload, Browse and History all work.
- Given I'm a guest, Then the app never forces me to sign up to finish a scan or view a care guide.

**US-03 Sign up / log in** · Must · F7
As a returning user, I want an account so that my history is kept.
- Given I'm on the access screen or in Settings, When I sign up with valid details, Then I'm logged in and reach Home.
- Given wrong login details, When I submit, Then I see a plain-language error and stay on the form.
- Given I'm logged in, When I tap **Log out**, Then I go back to guest mode.

**US-04 Import guest history on sign-up** · Should · F7, Q10
As a guest with saved scans, I want to bring them into my new account so that I don't lose them.
- Given I have N > 0 guest scans, When I finish sign-up, Then I'm asked "Import N scans?", and **Yes** adds them to my account history.
- Given I choose **No**, Then my guest scans stay on this device and are not linked to my account.

**US-05 Sync history across devices** · Should · F7
As a registered user, I want my history on any phone I log in to.
- Given I scanned on device A while logged in, When I log in on device B with internet, Then that scan appears in History on device B.

---

## Epic E2 — Scan & identify (F1, F2, F3)

**US-10 Scan with camera** · Must · F1, R2
As a user, I want to photograph a fabric so that the app can identify it.
- Given camera permission is not granted yet, When I tap **Scan**, Then the app explains why it needs the camera, then asks for permission.
- Given permission is denied, Then I see how to enable it in phone Settings, and **Upload** is offered instead.
- Given the camera is open, Then I see a framing guide and a short photo tip.
- When I capture, Then I can **Use photo** or **Retake**.

**US-11 Upload photo** · Must · F2, R2
As a user, I want to choose an existing photo so that I can identify fabric I photographed earlier.
- Given I tap **Upload**, When I pick an image from my gallery, Then I go to the same review step as US-10.
- Given the file is not an image, or can't be read, Then I see "Couldn't open this photo. Try another."

**US-12 Confident result** · Must · F3, PRD §6 state A
As a user, I want a clear answer when the app is confident.
- Given the top match meets the "confident" threshold, Then I see one fabric card with: name, fiber content, a "High match" label, identifying features, category tags, and **View care guide**.
- Then the screen never shows "100%" or "certain".
- Then "Not right? See other possible matches" opens a list of the next matches.

**US-13 Unsure result** · Must · F3, PRD §6 state B
As a user, I want to compare likely options when the app is unsure so that I can choose the right one.
- Given the result meets the "unsure" rule, Then I see "This could be…" with the top 3 cards and their identifying features.
- When I tap a card, Then its care guide opens, and History saves the fabric I chose.

**US-14 Can't identify** · Must · F3, PRD §6 state C, Q15
As a user, I want honest feedback when the app can't tell, so that I'm not misled.
- Given the confidence is below the minimum, or the photo is not fabric, Then I see "We couldn't identify this fabric", retake tips, **Retake**, **Browse fabrics**, and the scope note naming the 4 categories.
- Then nothing is saved to History, unless I then choose a fabric from Browse.

**US-15 Fiber ambiguity hint** · Must · F3
As a user, I want to know when the fiber is uncertain, so that I check the label.
- Given the identified fabric has more than one fiber version, Then the result lists all of them and shows "Check the garment label to confirm fiber."

**US-16 Result speed** · Must · N2
- Given a mid-range phone, When I tap **Use photo**, Then the result appears within 5 s (95% of the time in testing). While waiting, I see a progress indicator.

---

## Epic E3 — Care guidance (F4, F11)

**US-20 View care guide** · Must · F4, R3
As a user, I want care steps for my fabric so that I don't damage the garment.
- Given a fabric, When I open its care guide, Then I see 5 sections in this order: Washing, Drying, Ironing, Stain removal, Storage.
- Each section is short numbered steps and shows its citation(s) (expandable "Sources").
- Every care guide shows the disclaimer: "This is general guidance. Always follow the garment's care label if it differs."
- Care guides open with no internet connection.

**US-21 Stain-specific help** · Should · F4
As a user, I want stain removal advice for common stains so that I can act quickly.
- Given the Stain removal section, Then advice is grouped by stain type (at least: food or oil, sweat, make-up, and ink if the researchers provide it).

**US-22 Care-label symbols** · Could · F11, Q13
- Given the researchers supplied symbols, Then each section shows the matching ISO 3758 symbol with text for screen readers.

---

## Epic E4 — Browse & search (F5, F10)

**US-30 Browse by category** · Must · F5, R6
As a user, I want to look up fabrics without scanning.
- Given Home, When I tap **Browse**, Then I see 4 categories: Barong, Formal wear, Gowns & Filipiniana, Beaded Fabrics, each with its fabric count. *(Changed by CR-01, 2026-11-16.)*
- When I pick a category, Then I see its fabrics (image + name). A fabric that is in 2 categories appears in both.
- When I pick a fabric, Then I see its description, fiber content, identifying features and care guide.
- Browse works with no internet connection.

**US-31 Search fabrics** · Could · F10
- Given Browse, When I type at least 2 characters, Then fabrics whose name or alias matches are listed.

---

## Epic E5 — History (F6)

**US-40 Auto-save scans** · Must · F6, R4
- Given a result in state A, or a card I picked in state B, Then a history entry is saved with: thumbnail, fabric, confidence label, and date/time.

**US-41 View history** · Must · F6
- Given History, Then entries are listed newest first. Tapping one opens its saved result and care guide, with no internet needed.
- Given there are no entries, Then I see an empty state with a **Scan** button.

**US-42 Delete history** · Must · F6, N4
- I can delete a single entry (with a confirmation) and **Clear all** from Settings (with a confirmation).
- Given I'm logged in with sync, Then the deletion also applies to my account.

---

## Epic E6 — Help, about, evaluation (F8, F9)

**US-50 Help / how-to** · Must · F8, I2
- Help has the photo tips, plus how-to steps for scanning, browsing and history. The wording matches the user's manual.

**US-51 About & privacy** · Must · F8, N4
- About shows the study title, researchers, university, SDG 12 statement, app version, and a plain-language privacy note (what is stored and where).

**US-52 TAM survey link** · Should · F9, Q11
- Given the app is set up with a survey link, Then Settings/About shows **Take the survey**, which opens it in the browser.
- Given no link is set up, Then the button is hidden.

---

## Epic E7 — Content & release readiness (non-UI)

**US-60 Fabric catalog content complete** · Must · I4
As a researcher, I want every fabric's content finished so that the TAM build is credible.
- Every catalog fabric has all fields from `fabric-catalog.md` §1, at least 1 citation per care section, and a reviewer recorded.
- The TAM build contains no `[PLACEHOLDER]` text (checked automatically).

**US-61 Accuracy report** · Must · PRD §9
As a researcher, I want accuracy numbers I can put in the thesis.
- A report shows: top-1 and top-3 accuracy, accuracy per category and per fabric, and the confusion matrix, all on photos the scanner did not train on.

**US-62 Installable test builds** · Must · N6, Q8
- An Android APK and an iOS TestFlight build can be installed by respondents from a link or QR code, with the steps in the user's manual.

**US-63 Filipino language** · Won't (MVP) · F12

---

## MVP scope summary
Must: US-01–03, 10–16, 20, 30, 40–42, 50–51, 60–62 · Should: US-04, 05, 21, 52 · Could: US-22, 31 · Won't (MVP): US-63
