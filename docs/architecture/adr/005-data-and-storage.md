# ADR-005 — Data & storage: local-first SQLite + Firebase Firestore sync

**Status:** Accepted (2026-11-16) · **Traces to:** F6, F7, R4, R5, N3, N4, US-04, US-05, US-40–42, Q10, Q14

## Context
Guests need full history on the device. Logged-in users get sync across devices (Should). Free tier only, and **no backend that can go to sleep before a demo**. Photos are personal data (Data Privacy Act of 2012, RA 10173).

## Options
| | Firebase (Auth + Firestore), Spark plan | Supabase free | Custom backend |
|---|---|---|---|
| Flutter support | First-party FlutterFire | Good community SDK | DIY |
| Free-tier risk | No pausing; Firestore 1 GiB + 50k reads/day | **Projects pause after about 1 week of inactivity**, a real risk on demo day | Hosting cost + operations work |
| Photo storage | Cloud Storage for new projects needs the paid Blaze plan → **avoid**; store a tiny thumbnail inside the Firestore document instead | 1 GB storage | — |
| Offline | Built-in Firestore cache | Manual | Manual |

## Decision
- **Local source of truth:** SQLite via **`drift`** for all users. History works offline and for guests.
- **Cloud (logged-in only):** **Firebase Auth + Cloud Firestore, Spark (free) plan.** Path `users/{uid}/scans/{scanId}`.
- **Photos:**
  - Full-size photos are **never uploaded and never kept**. After inference the app keeps only a **256 px JPEG thumbnail (≤ 30 KB)** on the device.
  - For logged-in users with sync, that thumbnail is stored base64-encoded inside the Firestore document (the document limit is 1 MiB, so this fits easily). **No Cloud Storage** is used.
- **Sync:** each scan row carries `syncStatus` (`local`, `pending`, `synced`) and `deletedAt` (a soft-delete marker). A `SyncService`:
  - pushes pending and deleted rows when online and logged in;
  - pulls the user's scans after login and when the app starts;
  - resolves conflicts by `updatedAt` (the newer change wins). Scans rarely change after they're created, so this is enough.
- **Guest → account (US-04):** after sign-up, ask to import. If yes, set `ownerUid` and `syncStatus = pending` on the guest rows. If no, leave them as they are.
- **Logout:** ask whether to keep or remove this account's scans on the device. The default is remove, for privacy on shared phones.

## Consequences
- The paid Blaze plan is not needed. If a Firebase project is ever upgraded to Blaze, add a budget alert at ₱0.
- Firestore security rules must restrict `users/{uid}/**` to `request.auth.uid == uid` (tested with the emulator).
- Account deletion must remove `users/{uid}` and the Auth user (see Q16).
