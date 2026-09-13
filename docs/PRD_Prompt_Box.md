# Product Requirements Document: Prompt Manager App

**Author:** Devit Nur Azaqi
**Status:** Draft v2 (scope disederhanakan — fitur LLM testing dihapus)
**Last Updated:** 2026-09-11

---

## 1. Executive Summary

**Problem Statement:**
Developer dan power-user AI sering punya banyak prompt tersebar di notes app, chat history, atau file lepas, sulit dicari, dikategorikan, dan tidak punya referensi visual untuk prompt image-generation. Tidak ada satu tempat terpusat untuk mengelola dan mengorganisasi prompt beserta hasil visualnya.

**Proposed Solution:**
Aplikasi mobile (Flutter + Supabase) berbentuk gallery: dashboard menampilkan grid card semua prompt (dengan gambar hasil di atas card jika ada), tap card membuka halaman detail. Prompt bisa dikategorikan, ditag, dicari, dan dibagikan (public/private). Untuk prompt image-generation, user bisa melampirkan gambar hasilnya sebagai referensi visual.

**Success Criteria:**
- Aplikasi selesai dibangun dan berjalan stabil tanpa bug kritis dalam window deadline (1 minggu untuk MVP).
- Dapat didemokan penuh (create, organize, browse gallery, view detail, publish) sebagai portofolio teknis dalam wawancara kerja.
- Core flow (create prompt → lihat di grid dashboard → tap → lihat detail, termasuk gambar jika ada) berjalan end-to-end tanpa crash.
- Codebase terstruktur rapi (clean architecture ringan) sehingga bisa dijelaskan secara teknis ke interviewer.
- UI grid gallery terasa rapi dan polished — ini sekarang jadi fitur visual utama yang membedakan app dari CRUD list biasa.

⚠️ **Perubahan besar dari draft v1:** Fitur direct LLM API testing (Edge Function, Supabase Vault, tabel `test_runs` dan `user_api_keys`) **dihapus total** dari scope. Ini secara signifikan menurunkan kompleksitas teknis dan risiko deadline. Success criteria di atas berlaku untuk scope MVP yang sudah disederhanakan ini.

---

## 2. User Experience & Functionality

### User Personas

| Persona | Deskripsi | Kebutuhan Utama |
|---|---|---|
| **Primary: Devit (builder/demo user)** | Developer yang membangun app ini sebagai portofolio, sekaligus pengguna utama untuk kebutuhan personal | Tempat rapi menyimpan & menguji prompt kerja sehari-hari |
| **Secondary: Recruiter/Interviewer** | Melihat app ini sebagai bukti kemampuan teknis | UI jelas, alur logis, kode bisa dijelaskan, tidak crash saat didemokan |
| **Tersier (future): Public user** | User lain yang browse/pakai prompt publik | Discovery prompt bagus, fork/copy dengan mudah (di luar scope 5 hari) |

### User Stories & Acceptance Criteria

**US-1:** Sebagai user, saya ingin membuat dan menyimpan prompt dengan judul, isi, kategori, dan tag, supaya saya bisa mengorganisasi koleksi prompt saya.
- AC: Form create/edit prompt tersimpan ke Supabase dalam < 2 detik.
- AC: Validasi field wajib (title, content) sebelum submit.
- AC: Prompt baru langsung muncul di dashboard tanpa perlu refresh manual.

**US-2:** Sebagai user, saya ingin melihat semua prompt saya dalam bentuk grid card di dashboard, dengan gambar hasil (jika ada) tampil di atas card, supaya saya cepat mengenali prompt secara visual.
- AC: Dashboard menampilkan grid (2 kolom untuk mobile) berisi card prompt.
- AC: Card dengan `result_image_url` terisi menampilkan gambar di bagian atas card; card tanpa gambar menampilkan placeholder netral (mis. ikon atau warna kategori) — bukan gambar kosong yang janggal.
- AC: Card menampilkan minimal title dan kategori/tag utama.

**US-3:** Sebagai user, saya ingin tap sebuah card untuk membuka halaman detail prompt tersebut, supaya saya bisa melihat isi lengkap dan gambar hasilnya.
- AC: Halaman detail menampilkan title, content lengkap, kategori, tag.
- AC: **Jika prompt punya `result_image_url` (dianggap prompt image-generation), tampilkan gambar hasil secara penuh.** Jika `result_image_url` kosong, section gambar tidak dirender sama sekali (bukan placeholder kosong) — layout detail otomatis menyesuaikan tanpa ruang kosong yang canggung.
- AC: Ada tombol edit dan delete di halaman detail.

**US-4:** Sebagai user, saya ingin mencari dan memfilter prompt berdasarkan kategori/tag/kata kunci, supaya saya cepat menemukan prompt yang saya butuhkan di dashboard grid.
- AC: Search berbasis title/content, hasil grid ter-filter real-time saat mengetik (debounce).
- AC: Filter kategori dan tag bisa dikombinasikan.

**US-5:** Sebagai user, saya ingin (opsional) melampirkan gambar hasil generate saat membuat/edit prompt, supaya prompt image-generation punya referensi visual yang muncul di grid dan detail.
- AC: Field upload gambar bersifat opsional saat create/edit, tidak memblokir save jika kosong.
- AC: Gambar tersimpan di Supabase Storage, URL terhubung ke kolom `result_image_url` pada prompt terkait.

**US-6:** Sebagai user, saya ingin membagikan prompt tertentu sebagai publik, supaya orang lain (mis. interviewer) bisa melihat contoh kerja saya.
- AC: Toggle `is_public` pada prompt.
- AC: Halaman "Explore" menampilkan grid prompt publik dari semua user, layout sama dengan dashboard pribadi.

### Non-Goals (Out of Scope untuk v1/MVP)

- Direct LLM API testing dari dalam app (dihapus dari scope sepenuhnya — lihat catatan di Bagian 1)
- Versioning/history revisi prompt (v2.0, jika dibutuhkan)
- Fitur sosial: like, fork, comment, follow (v2.0, jika dibutuhkan)
- Monetisasi/marketplace, payment gateway (v2.0, eksplisit ditunda sesuai keputusan awal)
- Kolaborasi tim/multi-owner pada satu prompt
- Notifikasi push
- Multiple gambar per prompt (cukup 1 gambar hasil per prompt untuk MVP)

---

## 3. AI System Requirements

**Tidak berlaku (N/A) untuk scope ini.** Fitur direct LLM API integration sudah dihapus dari MVP. Tidak ada pemanggilan API eksternal ke LLM provider, tidak ada Edge Function, tidak ada penyimpanan API key user. Bagian ini dipertahankan sebagai section kosong untuk konsistensi schema PRD, dan diisi kembali jika fitur testing dihidupkan lagi di roadmap masa depan (lihat rekomendasi di bawah).

---

## 4. Technical Specifications

**Architecture Overview:**
- Flutter (Riverpod untuk state management) sebagai client.
- Supabase sebagai backend: Postgres (data), Auth (login), Storage (gambar hasil prompt).
- Data flow inti: `Flutter (form create/edit) → Supabase Storage (upload gambar, jika ada) → Postgres (simpan prompt + URL gambar) → Flutter (tampil di grid dashboard) → tap card → detail page (conditional render gambar)`.
- **Tidak ada Edge Function dan tidak ada Supabase Vault di scope ini** — kompleksitas backend jauh lebih rendah dibanding draft v1.

**Integration Points:**
- Supabase Auth (email/password untuk MVP).
- Supabase Storage bucket `prompt-results` untuk gambar hasil prompt.

**Security & Privacy:**
- RLS aktif di semua tabel: prompt privat hanya terlihat owner, prompt publik `SELECT`-only untuk non-owner.
- Storage RLS mengikuti visibilitas prompt (public prompt → gambar bisa diakses publik; private prompt → gambar hanya owner).

---

## 5. Risks & Roadmap

### Phased Rollout

| Fase | Scope | Target |
|---|---|---|
| **MVP (Hari 1-7)** | Auth dasar, CRUD prompt, kategori/tag, search, dashboard grid gallery, upload gambar opsional, detail page dengan render gambar kondisional, toggle public/private + halaman Explore | Demo-ready untuk interview |
| **v1.1 (pasca-deadline)** | UI/UX polish grid (animasi transisi, empty state, loading skeleton), image compression sebelum upload | Personal use jangka panjang |
| **v2.0 (opsional, jika dilanjutkan)** | Direct LLM API testing (fitur yang dihapus dari MVP ini, bisa dihidupkan kembali sebagai fitur lanjutan), versioning, fitur sosial | Jika mau dikembangkan jadi produk lebih lengkap |

⚠️ **Dampak positif dari penghapusan fitur LLM testing:** Deadline 1 minggu sekarang jauh lebih realistis. Tidak ada lagi risiko setup Supabase Vault atau Edge Function debugging. Waktu yang tadinya dialokasikan untuk itu bisa sepenuhnya masuk ke polish UI grid gallery, yang justru jadi fitur visual utama app ini.

### Technical Risks

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Grid gallery dengan gambar butuh perhatian ke performa loading (banyak card gambar sekaligus) | Sedang — scroll lag kalau tidak ditangani | Pakai lazy loading/cached image widget (mis. `cached_network_image`), jangan load semua gambar resolusi penuh sekaligus |
| Ukuran gambar upload tidak dibatasi bisa bikin Storage cepat penuh atau load lambat | Rendah-Sedang | Kompres/resize gambar di client sebelum upload (mis. batasi max 1080px, quality 80%) |
| Conditional rendering (gambar tampil/tidak tampil di detail) kalau tidak dites bisa bikin layout aneh | Rendah | Test manual eksplisit untuk 2 kasus: prompt dengan gambar dan tanpa gambar, pastikan keduanya rapi |

---

## 6. Rekomendasi Tambahan (Low-Complexity, Opsional)

Sesuai permintaan untuk menjaga kompleksitas tetap rendah, berikut rekomendasi yang **tidak wajib** tapi bisa menambah nilai demo tanpa menambah beban signifikan:

- 💡 **Empty state yang didesain niat**: dashboard kosong (belum ada prompt) tampilkan ilustrasi/CTA "Buat prompt pertama", bukan layar kosong polos. Efeknya besar untuk kesan visual saat demo, effort-nya kecil.
- 💡 **Badge tipe prompt di card**: label kecil "Image" vs "Text" di card grid berdasarkan ada/tidaknya `result_image_url`, supaya user cepat kenali jenis prompt tanpa buka detail. Cukup 1 widget conditional, tidak butuh kolom baru.
- 💡 **Copy-to-clipboard di detail page**: tombol copy untuk `content` prompt. Effort sangat kecil (built-in Flutter clipboard API), tapi menambah utilitas nyata.

Tidak direkomendasikan untuk MVP: dark mode custom, animasi kompleks, multi-bahasa. Semua itu menambah waktu tanpa menambah nilai demo secara proporsional untuk konteks portofolio 1 minggu.

---

## Appendix: Referensi Teknis Terkait

- Database migration: `001_init_schema.sql` — **perlu direvisi**, karena masih berisi tabel `test_runs` dan `user_api_keys` serta extension `pgsodium` yang sudah tidak relevan dengan scope ini. Beri tahu kalau mau gue regenerate migration file-nya.
- Stack: Flutter + Riverpod, Supabase (Postgres, Auth, Storage)
