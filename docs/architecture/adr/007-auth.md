# ADR-007 — Authentication: optional email/password via Firebase Auth

**Status:** Accepted (2026-11-16) · **Traces to:** F7, R5, US-02, US-03

## Context
Login is optional and guest mode is first-class. App Store guideline 4.8: if an app offers a third-party social login (e.g. Google), it must also offer an equivalent privacy-focused login such as Sign in with Apple. Accounts that can be created must also be deletable in the app (Apple 5.1.1(v), Google Play policy).

## Options
- Email/password only.
- Email + Google (+ Apple required on iOS).
- Anonymous Firebase Auth for guests, upgraded to a full account later.

## Decision
- **MVP: Firebase Auth email/password only**, with password reset by email. Email verification is sent but not required for using the app.
- **Guests are not authenticated at all.** Guests are purely local, with no anonymous Firebase account. This keeps guests fully offline with zero data in the cloud (N4).
- **Delete account** in Settings removes the Firestore data, then the Auth user. A proposed story was sent to the PM as Q16.
- **Later:** Google + Sign in with Apple together, when there is a store release.

## Consequences
- Avoids the Apple 4.8 requirement in the MVP.
- If respondents don't want to create a password, they can stay guests, since every core feature works without an account.
