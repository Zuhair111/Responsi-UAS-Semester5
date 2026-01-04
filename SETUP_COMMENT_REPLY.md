# Setup Comment Reply Feature

## Langkah 1: Jalankan SQL Migration

Buka **Supabase Dashboard** → **SQL Editor** → Jalankan script berikut:

```sql
-- Add parent_comment_id field to comments table for reply functionality
ALTER TABLE comments 
ADD COLUMN IF NOT EXISTS parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE;

-- Add index for better performance when fetching replies
CREATE INDEX IF NOT EXISTS idx_comments_parent ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
```

## Langkah 2: Hot Reload

Tekan `r` di terminal untuk hot reload aplikasi.

## Fitur yang Telah Ditambahkan

### 1. **Comment System**
   - Semua user bisa komentar di post orang lain
   - Real-time dari database Supabase
   - Avatar dan nama user ditampilkan

### 2. **Reply to Comment**
   - Tekan "Reply" di bawah komentar
   - Komentar reply akan muncul dengan indentasi
   - Nested comments untuk percakapan yang lebih jelas

### 3. **Visual Distinction**
   - **Pemilik Post**: Background orange + badge "Author"
   - **User Lain**: Background abu-abu netral
   - **Reply**: Indentasi ke kanan dengan avatar lebih kecil

### 4. **Delete Comment**
   - User bisa delete komentar sendiri
   - Icon trash muncul di komentar milik user
   - Konfirmasi sebelum delete

### 5. **Time Stamps**
   - "Just now", "5m ago", "2h ago", "3d ago", dll
   - Format yang user-friendly

## Cara Menggunakan

### Membuat Komentar:
1. Buka post (tap comment icon)
2. Ketik komentar di input box bawah
3. Tekan icon send (arrow)

### Reply Komentar:
1. Tekan "Reply" di bawah komentar
2. Muncul indicator "Replying to [nama]"
3. Ketik reply dan send
4. Tekan X untuk cancel reply

### Delete Komentar:
1. Lihat komentar yang Anda buat
2. Tekan icon trash di sebelah kanan
3. Konfirmasi delete

## UI Features

- **Komentar Pemilik Post**: 
  - Background: Orange dengan opacity
  - Border: Orange
  - Badge: "Author" dengan background orange solid
  - Text nama: Orange bold

- **Komentar User Lain**:
  - Background: Abu-abu terang
  - Text nama: Hitam bold

- **Reply Indentation**:
  - Margin kiri 40px
  - Avatar lebih kecil (radius 16 vs 20)
  - Font size lebih kecil

## Database Schema

```sql
comments (
  id UUID PRIMARY KEY,
  post_id UUID (FK to posts),
  user_id UUID (FK to auth.users),
  parent_comment_id UUID (FK to comments) -- NULL for top-level, ID for reply,
  content TEXT,
  created_at TIMESTAMP
)
```

## Notes

- Comments dengan `parent_comment_id = NULL` adalah top-level comments
- Comments dengan `parent_comment_id = [ID]` adalah replies
- Recursive delete: Jika parent comment dihapus, semua reply ikut terhapus
