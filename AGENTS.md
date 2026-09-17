# PromptBox

Mobile prompt manager app — gallery UI for organizing, categorizing, and sharing AI prompts with optional result images. Flutter + Riverpod + Supabase.

## Commands

- `flutter run` — run on connected device/emulator
- `flutter run -d chrome` — run on Chrome (web debug)
- `flutter analyze` — static analysis (uses `analysis_options.yaml` with `flutter_lints`)
<!-- - `flutter test` — run all unit/widget tests
- `flutter test test/<file>_test.dart` — run a single test file -->
- `flutter build apk --release` — release APK build
- `flutter pub get` — install dependencies after editing `pubspec.yaml`

## Gotchas

- **DB migration `001_init_schema.sql` is stale** → still contains `test_runs`, `user_api_keys`, and `pgsodium` extension from the removed LLM-testing scope. Regenerate before applying. Do not reference these tables in code.
- **No Edge Functions in scope** → all backend logic uses Supabase client SDK directly (Auth, Postgres, Storage). Do not create or reference Edge Functions.
- **Supabase Storage bucket is `prompt-results`** → image URLs stored in prompt field `result_image_url`. RLS on storage follows prompt visibility (public prompt = public image, private = owner-only).
- **Conditional image rendering is a layout trap** → detail page: if `result_image_url` is null, do not render any image section or empty placeholder; content shifts up. Card grid: use a neutral visual placeholder (category color or icon), never an empty image container. Test both variants (with image, without image) to catch layout glitches.
- **`cached_network_image` required for grid performance** → the dashboard loads many image thumbnails simultaneously. Always use `CachedNetworkImage` with `BoxFit.cover` on card thumbnails. Without it, scroll lag on image-heavy grids.
- **Image upload max 1080px width, quality 80%** → compress/resize on client before uploading to Supabase Storage. Unbounded uploads fill the bucket and cause slow loads.
- **Auth is email/password + Google Sign-In** → Apple sign-in button in the UI is a visual placeholder only. Google Sign-In uses Supabase native OAuth flow (`signInWithOAuth`). Deep link scheme: `io.supabase.promptbox://login-callback`.
- **RLS must be active on all tables** → private prompts: owner-only access. Public prompts: `SELECT`-only for non-owner. Every new table or migration must include RLS policies. Never disable RLS "temporarily."

## Conventions

- **Feature-based clean architecture**: `lib/core/` for shared code (theme, widgets, utils), `lib/features/<name>/` for feature modules (auth, dashboard, prompt, explore, profile). Each feature owns its own models, providers, and screens.
- **State management: Riverpod only** → no `setState` for shared state, no `ChangeNotifier`. Use `StateNotifierProvider` or `AsyncNotifierProvider`. `setState` is acceptable only for local widget state (animations, form focus).
- **Design system: Neo-Brutalism** → all components use design tokens from `lib/core/theme/` (colors, typography, spacing, shadows). Do not use Material defaults for buttons, cards, or inputs — use the custom `Brutal*` widgets (`BrutalButton`, `BrutalCard`, `BrutalInput`). Key visual rules:
  - Border: `2px solid #111111` (emphasis: `3px`)
  - Hard shadow: `4px 4px 0 #111111` (not Material elevation)
  - Radius: `4-8px` (not large rounded corners)
  - Background: `#F5F0E8` (warm off-white, not pure white or dark)
  - Primary accent: `#FF5C35`
- **Prompt badge logic** → `result_image_url != null` = IMAGE badge (green), `result_image_url == null` = TEXT badge. No new database column needed.
- **Grid layout: 2-column on mobile** → use `SliverGrid` or `GridView.builder` with `crossAxisCount: 2`, gap `10-12px`, page padding `16-20px`.

## References

- PRD (scope, user stories, acceptance criteria): `docs/PRD_Prompt_Box.md`
- Design system (colors, typography, components, screen specs): `docs/DESIGN.md`
- Design Images: `docs/Design-UI.png`
