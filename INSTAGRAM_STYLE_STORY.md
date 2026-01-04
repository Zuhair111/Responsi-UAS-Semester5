# Story Feature - Instagram Style Update

## ✅ Fitur Baru yang Ditambahkan

### 🎨 Tampilan Story Seperti Instagram

1. **Avatar User + Tombol Plus**
   - Foto profil user ditampilkan pertama
   - Tombol **+** di pojok kanan bawah untuk upload story
   - Text "Cerita Anda" di bawah avatar

2. **Outline Merah untuk Story Belum Dilihat**
   - Story yang belum dilihat: **Outline Merah** (gradient merah)
   - Automatic tracking per story per user

3. **Outline Abu-Abu untuk Story Sudah Dilihat**
   - Setelah lihat story: Outline berubah **Abu-Abu**
   - Persisten di database

4. **Badge Jumlah Story**
   - Angka di pojok avatar menunjukkan jumlah story
   - Badge merah jika ada story belum dilihat
   - Badge abu jika semua sudah dilihat

## 📋 Setup Database

Jalankan SQL migration baru di Supabase:

```sql
-- Copy paste isi file supabase_migration_story_views.sql
```

File: `supabase_migration_story_views.sql`

Table yang dibuat:
- `story_views` - Track siapa sudah lihat story siapa

## 🎯 Cara Kerja

### Upload Story
1. Klik avatar user dengan tombol **+**
2. Pilih gambar
3. Share

### View Story
1. Tap avatar dengan **outline merah** (belum dilihat)
2. Story ditampilkan
3. **Otomatis dicatat sebagai "sudah dilihat"**
4. Outline berubah jadi **abu-abu**

### Tracking View
- Setiap kali user membuka story: `markStoryAsViewed()` dipanggil
- Data disimpan di table `story_views`
- Query check viewed status saat load stories
- Outline color update otomatis

## 🔍 Logic Detail

### Outline Color Logic
```dart
hasUnviewed = stories.any((story) => !story.isViewed);

if (hasUnviewed) {
  // RED gradient
  colors: [Color(0xFFFF0000), Color(0xFFFF6B6B)]
} else {
  // GREY gradient  
  colors: [Colors.grey, Colors.grey.shade400]
}
```

### View Tracking
```dart
// Saat buka story
_markCurrentStoryAsViewed();

// Saat next/previous story
_nextStory() {
  _markCurrentStoryAsViewed(); // Track new story
}
```

## 📁 File Changes

**Baru:**
- `supabase_migration_story_views.sql` - Database migration

**Updated:**
- `lib/models/story_model.dart` - Tambah `isViewed` property
- `lib/services/story_service.dart` - Tambah view tracking methods
- `lib/pages/home_page.dart` - Update UI dengan outline merah/abu
- `lib/pages/story_view_page.dart` - Auto mark as viewed

## 🎨 UI Breakdown

### Story Avatar User
```
┌─────────────┐
│   Avatar    │  ← Foto profil
│     (+)     │  ← Tombol + pojok kanan bawah
└─────────────┘
  Cerita Anda
```

### Story User Lain (Belum Dilihat)
```
┌──RED RING──┐
│   Avatar    │  ← Foto user lain
│     (3)     │  ← Badge merah: 3 stories
└─────────────┘
   Username
```

### Story User Lain (Sudah Dilihat)
```
┌──GREY RING─┐
│   Avatar    │  ← Foto user lain
│     (3)     │  ← Badge abu: 3 stories
└─────────────┘
   Username
```

## 🚀 Testing

1. **Setup Database:**
   ```
   Supabase → SQL Editor → 
   Paste supabase_migration_story_views.sql → Run
   ```

2. **Test Upload:**
   - Klik avatar user + tombol +
   - Upload story

3. **Test View Tracking:**
   - Lihat story user lain (outline merah)
   - Keluar dari story
   - Check outline berubah abu-abu ✅

4. **Test Multiple Stories:**
   - Upload 3 stories
   - Badge menunjukkan angka 3
   - Outline merah jika ada yang belum dilihat

## 💡 Tips

- **Warna merah** menggunakan `Color(0xFFFF0000)` (pure red seperti Instagram)
- **Badge counter** menunjukkan total stories per user
- **View tracking** bekerja per story, bukan per user
- **Auto-reload** setelah view story untuk update outline

## 🔧 Troubleshooting

### Outline tidak berubah warna?
```sql
-- Check table story_views
SELECT * FROM story_views WHERE viewer_id = 'YOUR_USER_ID';
```

### Badge tidak muncul?
- Check user punya > 1 story
- Restart app

### Database error?
- Pastikan table `stories` sudah ada
- Jalankan migration `story_views` setelah migration `stories`

## 📸 Hasil Akhir

Tampilan story sekarang **persis seperti Instagram**:
- ✅ Outline merah untuk unread
- ✅ Outline abu untuk read
- ✅ Avatar user dengan tombol +
- ✅ Badge counter
- ✅ Automatic tracking

Enjoy! 🎉
