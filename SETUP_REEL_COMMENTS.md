# Reel Comments & Share Setup Guide

Panduan lengkap untuk mengaktifkan fitur komentar, balasan, dan share pada reels.

## 1. Database Setup

### Jalankan SQL Migration

Buka Supabase Dashboard → SQL Editor → Jalankan script berikut:

```sql
-- File: supabase_migration_reel_comments.sql
-- Tabel untuk komentar reels
CREATE TABLE IF NOT EXISTS reel_comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  reel_id UUID REFERENCES reels(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  comment TEXT NOT NULL,
  parent_comment_id UUID REFERENCES reel_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_reel_comments_reel_id ON reel_comments(reel_id);
CREATE INDEX IF NOT EXISTS idx_reel_comments_user_id ON reel_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_reel_comments_parent_id ON reel_comments(parent_comment_id);

-- Tambah kolom comments_count ke tabel reels
ALTER TABLE reels ADD COLUMN IF NOT EXISTS comments_count INTEGER DEFAULT 0;

-- Trigger untuk auto update comments_count
CREATE OR REPLACE FUNCTION update_reel_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE reels SET comments_count = comments_count + 1
    WHERE id = NEW.reel_id AND NEW.parent_comment_id IS NULL;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE reels SET comments_count = GREATEST(0, comments_count - 1)
    WHERE id = OLD.reel_id AND OLD.parent_comment_id IS NULL;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_reel_comments_count
AFTER INSERT OR DELETE ON reel_comments
FOR EACH ROW
EXECUTE FUNCTION update_reel_comments_count();

-- RLS Policies untuk reel_comments
ALTER TABLE reel_comments ENABLE ROW LEVEL SECURITY;

-- Policy: Semua user bisa lihat komentar
CREATE POLICY "Reel comments are viewable by everyone" 
ON reel_comments FOR SELECT 
USING (true);

-- Policy: Authenticated user bisa insert komentar
CREATE POLICY "Authenticated users can insert comments" 
ON reel_comments FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: User hanya bisa hapus komentar sendiri
CREATE POLICY "Users can delete own comments" 
ON reel_comments FOR DELETE 
USING (auth.uid() = user_id);

-- Policy: User hanya bisa update komentar sendiri
CREATE POLICY "Users can update own comments" 
ON reel_comments FOR UPDATE 
USING (auth.uid() = user_id);
```

## 2. Flutter Implementation

### A. ReelService Functions (Sudah ada)

```dart
// Tambah komentar
Future<void> addComment(String reelId, String comment, {String? parentCommentId}) async

// Ambil komentar (parent comments)
Future<List<Map<String, dynamic>>> getComments(String reelId) async

// Ambil balasan (replies)
Future<List<Map<String, dynamic>>> getReplies(String commentId) async

// Hapus komentar
Future<void> deleteComment(String commentId) async
```

### B. ReelCommentsPage (Sudah ada)

UI untuk menampilkan dan mengelola komentar dengan fitur:
- Tampilkan semua komentar
- Reply ke komentar
- Hapus komentar sendiri
- Indikator loading
- Format waktu dengan timeago

### C. ReelItem Widget (Sudah diupdate)

Tombol komentar dan share sudah terintegrasi:
- **Comment button**: Navigasi ke ReelCommentsPage
- **Share button**: Menampilkan bottom sheet dengan opsi:
  - Copy Link
  - Share via... (menggunakan share_plus)

## 3. Testing Checklist

### Testing Komentar
- [ ] Bisa menambahkan komentar baru
- [ ] Komentar muncul di list dengan nama user
- [ ] Counter comments_count bertambah
- [ ] Bisa reply ke komentar
- [ ] Reply muncul dengan indent
- [ ] Bisa hapus komentar sendiri
- [ ] Komentar hilang setelah dihapus
- [ ] Counter berkurang setelah hapus

### Testing Share
- [ ] Tombol share muncul di reel
- [ ] Bottom sheet muncul saat klik share
- [ ] Copy link berfungsi
- [ ] Share via... membuka native share dialog
- [ ] Link dan caption ter-share dengan benar

## 4. Troubleshooting

### Masalah: Komentar tidak muncul
**Solusi:**
1. Cek RLS policies sudah diaktifkan
2. Cek user sudah login (auth.uid() tidak null)
3. Cek console log untuk error dari Supabase

### Masalah: Comments_count tidak update
**Solusi:**
1. Pastikan trigger sudah dijalankan
2. Cek apakah kolom comments_count ada di tabel reels
3. Reload data dari database

### Masalah: Share tidak berfungsi
**Solusi:**
1. Pastikan package share_plus sudah terinstall
2. Untuk Android, pastikan android:minSdkVersion >= 21
3. Test di real device, share mungkin tidak bekerja di emulator

### Masalah: Reply tidak muncul
**Solusi:**
1. Cek parent_comment_id terisi dengan benar
2. Cek query getReplies() menggunakan parent_comment_id yang tepat
3. Lihat console log untuk error

## 5. Dependencies

Package yang dibutuhkan (sudah ada di pubspec.yaml):
```yaml
dependencies:
  share_plus: ^10.1.2
  timeago: ^3.7.0
  supabase_flutter: ^2.8.0
```

## 6. File Structure

```
lib/
├── services/
│   └── reel_service.dart          # Comment functions
├── pages/
│   └── reel_comments_page.dart    # Comments UI
└── widgets/
    └── reel_item.dart             # Share integration

supabase_migration_reel_comments.sql  # Database schema
```

## 7. Best Practices

1. **Validasi Input**: Cek komentar tidak kosong sebelum submit
2. **Loading State**: Tampilkan loading saat add/delete comment
3. **Error Handling**: Tangkap error dari Supabase dan tampilkan pesan
4. **Optimistic UI**: Update UI dulu, baru sync ke database
5. **Cache**: Consider caching comments untuk performa lebih baik

## 8. Next Steps

Setelah setup selesai:
1. Test di real device (Android/iOS)
2. Test comment threading (reply to reply)
3. Add pagination untuk komentar jika banyak
4. Add mention users (@username)
5. Add like untuk komentar

## Notes

- Migration SQL sudah include trigger untuk auto-update counter
- RLS policies sudah diatur untuk keamanan
- Share menggunakan native share dialog di setiap platform
- Timeago package untuk format waktu relatif (e.g., "2 hours ago")
