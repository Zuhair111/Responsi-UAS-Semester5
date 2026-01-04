# Quick Setup - Story Feature

## Setup Database (5 menit)

1. **Buka Supabase Dashboard**
   - Login ke https://supabase.com
   - Pilih project Anda

2. **Jalankan SQL Migration**
   - Klik "SQL Editor" di sidebar
   - Klik "New Query"
   - Copy paste isi file `supabase_migration_stories.sql`
   - Klik "Run" atau tekan Ctrl+Enter

3. **Verify Table Created**
   - Klik "Table Editor" di sidebar
   - Cari table "stories"
   - Pastikan ada columns: id, user_id, image_url, created_at, expires_at

## Test App (2 menit)

### 1. Upload Story
```
Home Page → Klik "Add Story" → 
Pilih gambar → Klik "Share"
```

### 2. View Story
```
Home Page → Klik story avatar → 
Story ditampilkan
```

### 3. Send Message dari Story
```
Saat lihat story → Ketik pesan → 
Klik tombol send → Check Chat List
```

## Fitur Utama

✅ Upload story dengan gambar  
✅ Story expire dalam 24 jam  
✅ View multiple stories per user  
✅ **Kirim komentar langsung ke chat**  

## Cara Kerja Komentar di Story

```
1. User melihat story orang lain
2. Ketik pesan di story viewer
3. Klik send
4. Pesan otomatis masuk ke chat conversation
5. Penerima dapat melihat di Chat List
```

**Tidak perlu:**
- Navigate ke profile
- Cari user di chat
- Start conversation manual

**Sistem otomatis:**
- Create conversation (jika belum ada)
- Kirim pesan
- Update chat list

## Troubleshooting

### Story tidak muncul?
```sql
-- Check di SQL Editor:
SELECT * FROM stories WHERE expires_at > NOW();
```

### Upload error?
- Check internet connection
- Check file size < 5MB
- Check image format (jpg, png)

### Message tidak terkirim?
- Pastikan table messages ada
- Check function get_or_create_conversation
- Login ulang jika perlu

## File Changes

**Baru:**
- `lib/models/story_model.dart`
- `lib/services/story_service.dart`
- `lib/pages/create_story_page.dart`
- `supabase_migration_stories.sql`

**Updated:**
- `lib/pages/story_view_page.dart`
- `lib/pages/home_page.dart`

## Support

Issues? Check:
1. Console logs (Debug Console)
2. Supabase logs (Dashboard → Logs)
3. Network tab untuk API calls
4. File STORY_FEATURE_GUIDE.md untuk detail lengkap
