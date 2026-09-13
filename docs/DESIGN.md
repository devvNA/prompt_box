      # PromptBox — UI/UX Design System

> **Status:** Draft v1
> **Product:** Prompt Manager App
> **Design Direction:** Clean Editorial Neo-Brutalism
> **Platform:** Mobile (Flutter)
> **Primary Stack:** Flutter + Riverpod + Supabase
> **Reference:** Product Requirements Document (PRD), Draft v2 — 11 September 2026

---

## 1. Design Vision

PromptBox adalah aplikasi mobile untuk menyimpan, mengorganisasi, menemukan, dan membagikan prompt AI. Karena gallery prompt merupakan fitur visual utama, UI tidak boleh terasa seperti CRUD/admin dashboard biasa.

Arah visual yang dipilih:

**Clean Editorial Neo-Brutalism × AI Creative Tool**

Karakter visual:

- Bold dan ekspresif, tetapi tetap mudah dibaca.
- Border hitam tebal dan hard shadow.
- Bentuk komponen tegas dengan corner radius kecil.
- Background warm/off-white sebagai canvas utama.
- Warna aksen digunakan secara selektif.
- Typography besar dan kuat untuk heading.
- Card prompt menjadi elemen visual utama.
- Interaction terasa tactile: button dan card seperti benda fisik yang bisa ditekan.

Design tidak diarahkan menjadi neo-brutalism yang terlalu chaotic. Fokusnya adalah mempertahankan hierarchy, usability, dan readability.

---

## 2. Design Goals

### Primary Goals

1. Membuat gallery prompt terasa berbeda dari aplikasi notes atau CRUD biasa.
2. Membuat prompt image-generation mudah dikenali secara visual.
3. Membuat create → browse → detail menjadi flow yang sangat jelas.
4. Memberikan kesan polished saat dipakai sebagai portfolio/demo teknis.
5. Menjaga implementasi tetap realistis untuk MVP satu minggu.

### Non-Goals

Untuk MVP, design tidak perlu mencakup:

- Dark mode custom.
- Animasi kompleks.
- Multi-language UI.
- Social interaction yang kompleks.
- Multiple image per prompt.

---

## 3. Design Principles

### 3.1 Visual Hierarchy First

Heading, title prompt, CTA, dan image harus langsung terlihat. Decorative elements tidak boleh mengalahkan informasi utama.

### 3.2 Gallery Is the Hero

Dashboard utama menggunakan 2-column grid. Image hasil prompt menjadi visual anchor ketika tersedia.

### 3.3 Strong but Controlled Contrast

Gunakan warna terang untuk highlight, tetapi pertahankan ink/black sebagai elemen struktur utama.

### 3.4 Tactile Interaction

Button, filter, tab, dan card menggunakan border + hard shadow. Ketika ditekan, shadow dapat dikurangi sehingga memberikan efek pressed.

### 3.5 Conditional UI

Komponen hanya ditampilkan ketika memiliki data yang relevan. Contoh: jika prompt tidak memiliki `result_image_url`, detail page tidak menampilkan image section kosong.

### 3.6 Progressive Disclosure

Dashboard menampilkan informasi ringkas. Detail page menampilkan content lengkap dan action yang lebih lengkap.

---

# 4. Color System

## 4.1 Core Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#F5F0E8` | Main application background |
| `surface` | `#FFFDF8` | Card, form, modal surface |
| `ink` | `#111111` | Primary text, border, icon |
| `primary` | `#FF5C35` | Primary accent, important action |
| `yellow` | `#FFD84D` | Highlight, CTA, selected state |
| `green` | `#58D68D` | Public/success/image badge |
| `purple` | `#6C63FF` | Secondary accent/category |
| `danger` | `#E5484D` | Delete/destructive action |
| `muted` | `#767676` | Secondary text |
| `border-muted` | `#D8D2C7` | Low-emphasis divider |

## 4.2 Usage Rules

- Background utama selalu warm off-white.
- Ink/black dipakai untuk structure, bukan hanya typography.
- Maksimal 1-2 accent colors dominan dalam satu screen.
- Yellow cocok untuk selected state dan CTA secondary.
- Green cocok untuk public state, image badge, atau success.
- Red hanya untuk destructive action.

---

# 5. Typography

## 5.1 Font Direction

### Recommended

- **Heading:** Space Grotesk
- **Body/UI:** Plus Jakarta Sans

Fallback:

- Heading: `Arial Rounded / Inter`
- Body: `Inter / system sans-serif`

## 5.2 Type Scale

| Style | Size | Weight | Usage |
|---|---:|---:|---|
| Display | 34-40 | 800 | Onboarding hero |
| H1 | 28-32 | 800 | Page title |
| H2 | 22-24 | 700 | Section title |
| Card Title | 16-18 | 700 | Prompt title |
| Body | 14-16 | 400-500 | Main content |
| Caption | 11-12 | 500-600 | Metadata/tag |
| Button | 13-15 | 700 | CTA |

## 5.3 Typography Rules

- Heading dapat menggunakan uppercase pada label tertentu.
- Prompt title tidak boleh terlalu panjang di card.
- Content preview maksimal 2-3 lines.
- Body text memakai line-height nyaman, sekitar 1.4-1.6.

---

# 6. Neo-Brutalism Component Language

## 6.1 Borders

Default:

```text
Border: 2px solid #111111
```

Emphasis:

```text
Border: 3px solid #111111
```

## 6.2 Hard Shadow

Default card:

```text
4px 4px 0 #111111
```

Large CTA:

```text
5px 5px 0 #111111
```

Pressed state:

```text
transform: translate(3px, 3px)
shadow: 1px 1px 0 #111111
```

## 6.3 Radius

Default:

```text
4px - 8px
```

Avoid highly rounded modern SaaS UI shapes.

## 6.4 Spacing

Primary spacing scale:

```text
4 / 8 / 12 / 16 / 20 / 24 / 32
```

Mobile page padding:

```text
16px - 20px
```

Grid gap:

```text
10px - 12px
```

---

# 7. Core Components

## 7.1 Primary Button

Visual:

- Black background.
- White text.
- 2px black border.
- Hard shadow.
- Small radius.

Example:

```text
┌──────────────────────────┐
│      SAVE PROMPT  →      │
└──────────────────────────┘
         ▰▰▰▰
```

States:

- Default
- Pressed
- Disabled
- Loading

## 7.2 Secondary Button

White/cream background + black border + hard shadow.

## 7.3 Destructive Button

Red background with black border.

Use only for actions such as Delete.

## 7.4 Input Field

- Warm white surface.
- 2px black border.
- Small radius.
- Clear label above field.
- Focus state can use accent outline/background.

## 7.5 Tag / Chip

Tags harus terasa seperti label fisik:

```text
[ #cinematic ] [ #product ] [ #coffee ]
```

Recommended:

- 1px-2px border.
- Slightly tinted background.
- Compact typography.

## 7.6 Badge

Two important prompt types:

```text
[ IMAGE ]
[ TEXT ]
```

Badge ditentukan dari keberadaan `result_image_url`.

## 7.7 Filter Chip

Selected:

```text
[ ALL ]
```

Dengan yellow background + black border.

Unselected:

```text
[ Image ] [ Text ] [ Design ]
```

Dengan surface background.

---

# 8. Prompt Card

Prompt card merupakan komponen paling penting dalam aplikasi.

## 8.1 Image Prompt Card

Struktur:

```text
┌─────────────────────┐
│                     │
│      RESULT IMG     │
│                     │
├─────────────────────┤
│ [ IMAGE ]           │
│                     │
│ Cinematic Coffee... │
│                     │
│ #coffee #cinematic  │
│                     │
│ ♡ 24          ···   │
└─────────────────────┘
      ▰▰▰▰
```

## 8.2 Text Prompt Card

Tidak memiliki image area kosong.

Gunakan:

- Colored visual block.
- Large `TXT` badge.
- Optional abstract typography/pattern.

## 8.3 Card Rules

Card wajib menampilkan minimal:

- Title.
- Category atau badge.
- Primary tag.

Optional:

- Like count, jika nanti social feature ditambahkan.
- Owner/avatar pada Explore.
- Overflow menu.

Untuk MVP pribadi, jangan bergantung pada like/follow/comment karena fitur tersebut berada di luar scope.

---

# 9. Navigation Architecture

Bottom navigation untuk mobile:

```text
┌────────────────────────────────────┐
│  Home   Explore   Categories  Profile │
└────────────────────────────────────┘
```

## Navigation Items

### Home

Prompt milik user.

### Explore

Prompt publik dari seluruh user.

### Categories

Shortcut untuk browse/filter berdasarkan kategori.

### Profile

Profile, prompt count, settings, dan account actions.

## Global Create Action

Create Prompt adalah action utama.

Gunakan floating `+` atau prominent CTA pada Home.

---

# 10. Screen Specifications

## 10.1 Onboarding 1 — Save Your Prompts

Purpose:

Memperkenalkan fungsi inti aplikasi.

Content:

- PromptBox branding.
- Illustration character.
- Headline besar.
- Short description.
- Progress indicator.
- Next button.

Tone:

Friendly, bold, creative.

---

## 10.2 Onboarding 2 — Organize Your Ideas

Highlight:

- Categories.
- Tags.
- Visual preview.

Illustration dapat menggunakan stacked prompt cards.

---

## 10.3 Onboarding 3 — Share & Get Inspired

Highlight:

- Public prompts.
- Explore.
- Inspiration/community discovery.

CTA:

```text
GET STARTED →
```

---

## 10.4 Login

Structure:

```text
Logo
App tagline

[ Email ]
[ Password ]
Forgot password?

[ SIGN IN → ]

──── or continue with ────

[ Continue with Google ]
[ Continue with Apple ]
```

MVP authentication tetap email/password sesuai PRD. Social login dapat menjadi visual placeholder atau future enhancement bila belum diimplementasikan.

---

## 10.5 Sign Up

Fields:

- Name
- Email
- Password

Primary CTA:

```text
SIGN UP →
```

Footer:

```text
Already have an account? Sign In
```

---

## 10.6 Dashboard — My Prompts

Ini adalah **primary screen**.

Structure:

```text
PROMPTBOX                         Avatar

[ Search prompts... ]       [ Filter ]

[ All ] [ Image ] [ Text ] [ Design ]

┌─────────┐ ┌─────────┐
│ Card    │ │ Card    │
├─────────┤ ├─────────┤
│ Card    │ │ Card    │
└─────────┘ └─────────┘

                         [+]
────────────────────────────────────
 Home   Explore   Categories Profile
```

Requirements dari PRD:

- 2-column mobile grid.
- Search title/content.
- Category/tag filter.
- Card dengan gambar menampilkan gambar di atas card.
- Card tanpa gambar menggunakan placeholder visual netral.
- Prompt baru langsung muncul setelah save tanpa refresh manual.

---

## 10.7 Create Prompt

Fields:

1. Title
2. Content
3. Category
4. Tags
5. Result Image (optional)
6. Visibility

CTA:

```text
SAVE PROMPT →
```

Image upload preview harus muncul sebelum save.

Visibility control:

```text
[ 🔒 PRIVATE ] [ 🌐 PUBLIC ]
```

---

## 10.8 Edit Prompt

Edit menggunakan form yang sama seperti Create Prompt.

Perbedaan:

- Existing image ditampilkan.
- User dapat mengganti/remove image.
- CTA berubah menjadi `UPDATE PROMPT`.

---

## 10.9 Prompt Detail

Struktur:

```text
← BACK

[ IMAGE GENERATION ]

Cinematic Coffee Photography
────────────────────────────

FULL PROMPT CONTENT...

TAGS
[ #coffee ] [ #product ] [ #cinematic ]

────────────────────────────

[ COPY ] [ EDIT ] [ DELETE ]
```

Jika `result_image_url` tersedia:

- Render image penuh/large.
- Image menjadi hero visual.

Jika tidak tersedia:

- Jangan render image section.
- Content langsung naik ke area atas.

---

## 10.10 Explore

Tujuan:

Menampilkan prompt publik dari semua user.

Structure sama dengan dashboard sehingga user tidak perlu belajar layout baru.

Perbedaan:

- Search public prompts.
- Owner/avatar metadata.
- Public prompt context.

Contoh metadata:

```text
Public · 2 days ago · by Devit
```

Social actions seperti like/comment/fork tetap di luar MVP.

---

## 10.11 Profile

Profile screen berisi:

- Avatar.
- Name.
- Username/email.
- Prompt count.
- Public prompt count.
- Settings.
- My Prompts.
- Help & Feedback.
- Sign Out.

Social metrics tidak perlu dianggap MVP requirement.

---

# 11. Empty State

Empty state harus terasa intentional.

Contoh Dashboard kosong:

```text
        ✦

YOUR PROMPT LIBRARY
IS EMPTY.

Start saving your best ideas
and build your prompt collection.

[ CREATE FIRST PROMPT → ]
```

Gunakan illustration kecil atau abstract shape, bukan blank page.

---

# 12. Loading & Error States

## Loading

Prioritaskan:

- Skeleton card.
- Skeleton image.
- Button loading indicator.

Hindari spinner fullscreen untuk aksi kecil.

## Error

Error harus singkat dan actionable.

Contoh:

```text
Something went wrong.
Please try again.

[ TRY AGAIN ]
```

---

# 13. Interaction & Motion

Motion harus ringan karena MVP memiliki deadline pendek.

Recommended:

- Button press feedback.
- Card tap scale/translation kecil.
- Page transition standar Flutter.
- Image fade-in ringan.

Tidak direkomendasikan:

- Complex hero transitions.
- Parallax.
- Heavy animated background.
- Continuous decorative animation.

---

# 14. Accessibility & Readability

Minimal requirements:

- Text body harus memiliki contrast tinggi terhadap background.
- Button memiliki area tap yang cukup.
- Jangan hanya membedakan state dengan warna.
- Icon penting harus memiliki semantic label.
- Form validation harus menyebutkan field yang bermasalah.

Neo-brutalism tidak boleh menjadi alasan untuk mengorbankan usability.

---

# 15. Responsive Behavior

Walaupun target utama adalah mobile, layout harus tetap adaptif.

### Small Mobile

- 2-column grid.
- Card image ratio sekitar 4:5 atau 1:1.
- Padding 16px.

### Large Mobile / Tablet

- Grid dapat berubah menjadi 2-3 kolom.
- Padding dapat meningkat menjadi 24px.

Jangan memaksakan desktop-style sidebar pada MVP mobile.

---

# 16. Image Guidelines

Untuk prompt image-generation:

- Gunakan image sebagai visual anchor.
- Prioritaskan aspect ratio konsisten di card.
- Gunakan `BoxFit.cover` pada thumbnail.
- Detail page dapat menggunakan `BoxFit.contain` agar hasil tidak terpotong.
- Compress/resize image sebelum upload.
- Recommended maximum width: sekitar 1080px.

Technical source requirement dari PRD:

```text
Supabase Storage bucket: prompt-results
Prompt field: result_image_url
```

---

# 17. UX Rules per Prompt Type

## Image Prompt

```text
IMAGE → Hero Image → Prompt Content → Tags → Actions
```

## Text Prompt

```text
TEXT → Prompt Content → Tags → Actions
```

Jangan membuat image placeholder kosong pada detail prompt text.

---

# 18. MVP Design Priority

Urutan prioritas implementasi visual:

### P0 — Must Have

- Dashboard grid.
- Prompt card.
- Create form.
- Edit form.
- Detail page.
- Image upload preview.
- Search/filter UI.
- Public/private state.
- Explore grid.
- Login.

### P1 — High Value

- Empty state.
- Loading skeleton.
- Copy prompt.
- Pressed interaction.
- Image fade-in.

### P2 — Post MVP

- Advanced animation.
- Custom dark mode.
- Social interaction.
- Prompt version history.
- Rich sharing experience.

---

# 19. Flutter Implementation Notes

Design system sebaiknya dipetakan ke reusable widgets.

Recommended structure:

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_shadows.dart
│   │
│   └── widgets/
│       ├── brutal_button.dart
│       ├── brutal_card.dart
│       ├── brutal_input.dart
│       ├── prompt_badge.dart
│       ├── prompt_tag.dart
│       └── empty_state.dart
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── prompt/
│   ├── explore/
│   └── profile/
│
└── app.dart
```

Design token values should live centrally and tidak di-hardcode pada setiap screen.

---

# 20. Screen Inventory

| ID | Screen | Priority | Status |
|---|---|---|---|
| S01 | Onboarding 1 | P0 | Design |
| S02 | Onboarding 2 | P0 | Design |
| S03 | Onboarding 3 | P0 | Design |
| S04 | Login | P0 | Design |
| S05 | Sign Up | P0 | Design |
| S06 | Dashboard | P0 | Design |
| S07 | Create Prompt | P0 | Design |
| S08 | Edit Prompt | P0 | Design |
| S09 | Prompt Detail | P0 | Design |
| S10 | Explore | P0 | Design |
| S11 | Profile | P0 | Design |
| S12 | Empty State | P1 | Design |
| S13 | Loading/Error | P1 | Design |

---

# 21. Design Reference

The initial visual direction is represented by the generated UI storyboard covering:

- Onboarding.
- Login.
- Sign Up.
- Dashboard.
- Create/Edit Prompt.
- Prompt Detail.
- Explore.
- Profile.

The storyboard is a visual direction reference, not a pixel-perfect production specification. Final implementation should follow the tokens and rules in this document.

---

# 22. Final Design Principle

> **Make the prompt feel like an object, not just a row of database data.**

Setiap prompt harus terasa seperti collectible creative asset: punya visual identity, title yang kuat, category, tag, dan optional result image. Gallery menjadi tempat utama user memahami koleksinya secara visual.

The UI should feel:

**Bold. Tactile. Creative. Organized. Fast.**

Bukan:

**Corporate. Generic. Over-decorated. Chaotic.**
