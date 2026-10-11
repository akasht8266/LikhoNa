# LikhoNa Android — Production Starter
**Tagline:** दिल में है जो, लिखो ना!

This is a native React Native / Expo Android starter using the provided LikhoNa logo and a Supabase backend integration. It is a real starting codebase, not a finished/verified Play Store release. Cloud features work only after the owner creates and configures a Supabase project and runs the schema.

## Included in this starter
- Native Android app structure (Expo Router / React Native)
- Hindi/English language switch on login and main app; selection is saved on-device and restored on next launch
- Main navigation, feed, post composer, category labels, and profile headings translated in both languages
- Uploaded LikhoNa logo used in the login screen and app icon assets
- Email/password sign-up and login through Supabase Auth
- Auth session stored through Expo SecureStore
- Cloud profile read/update
- Cloud public-post feed and authenticated post publishing
- SQL schema, indexes, row-level security policies, and profile-on-signup trigger
- Environment variable template; no secret keys are included

## Not yet implemented — do not advertise as complete
Likes, comments, follows, bookmarks, push notifications, image uploads/storage policies, password reset UI, account deletion flow, admin/moderation dashboard, reports, rate limiting/anti-spam, content search, social-platform API publishing, web SEO site, automated tests, and production monitoring are not included yet. Some error/alert messages and secondary profile labels may still appear in Hindi; full localization QA is required before release. A production launch must complete these and undergo security/privacy/accessibility testing.

## Requirements
- Node.js LTS (use a currently supported LTS version; avoid experimental Node versions)
- Expo Go for a quick device preview, or Android Studio/emulator for native testing
- A Supabase account/project
- EAS account for cloud Android builds (recommended)

## Setup (Windows CMD)
1. Extract the ZIP into a simple path, e.g. `C:\LikhoNa`.
2. Install Node.js LTS from https://nodejs.org/ and verify `node -v` and `npm -v`.
3. Open CMD in this folder and run:
   ```cmd
   npm install
   copy .env.example .env
   ```
4. In Supabase, create a project. Open **Project Settings → API** and copy the Project URL and publishable/anon key. Put them in `.env` as `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`. Never put a `service_role` secret in a mobile app.
5. In Supabase **SQL Editor**, run the complete `supabase/schema.sql` file.
6. In Supabase **Authentication → URL Configuration**, configure allowed redirect/site URLs for the final app/site. For production, enable email verification and configure SMTP.
7. Run:
   ```cmd
   npx expo start
   ```
   Scan the QR with Expo Go for a development preview. Keep CMD open while testing.
8. Check TypeScript:
   ```cmd
   npm run typecheck
   ```

## Build an Android APK/AAB (after configuring EAS)
1. Install EAS CLI: `npm install -g eas-cli`
2. Log in: `eas login`
3. Configure project: `eas build:configure`
4. For a test APK, create/update `eas.json` with an Android preview profile using `"buildType": "apk"`, then run `eas build -p android --profile preview`.
5. For Play Store, use an AAB production profile and run `eas build -p android --profile production`; upload the resulting `.aab` to Play Console and complete its testing, data safety, privacy policy, content rating, and other required declarations.

Do not upload to Play Store until signup, verification, data access policies, error states, account deletion, abuse reporting, moderation, privacy disclosures, and device testing are completed.

## Important backend/security notes
- Only the Supabase publishable/anon key belongs in the client; database access is controlled by Row Level Security. Never ship a service-role key.
- This starter uses secure storage for the auth session. The database RLS policies are essential and must remain enabled.
- Test email verification and uniqueness handling. The current profile UI does not resolve username collisions with a friendly retry flow yet.
- Public profiles and public posts are readable by anyone as written in the schema. Adjust this if the product requires more privacy.
- Backups are not configured by this code. Configure Supabase project backups and test restore before launch.
- The app icon is generated from the supplied full logo. A production icon should be reviewed/cropped for legibility at small sizes.


## Hindi / English language support

The app has an in-app Hindi/English switch on the authentication screen and in the signed-in header. The selected language is saved locally and restored on next launch. All currently implemented app-owned UI labels, form hints, category names, and common validation/success messages use the translation dictionary in `app/index.tsx`. User-generated poetry and profile names are intentionally not translated. Category values are stored as stable keys (`shayari`, `poetry`, etc.) so they display in the selected language without changing user content. Review all newly added screens and third-party error messages for localization before production release.
