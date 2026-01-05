# 🔴 ENABLE REALTIME - WAJIB DIJALANKAN! 

## ⚠️ Masalah Saat Ini

Real-time subscriptions sudah di-setup di Flutter code, tapi **TIDAK BEKERJA** karena:
- ❌ Realtime belum di-enable di Supabase untuk table posts, reels, messages
- ❌ Channel subscriptions tidak menerima data baru
- ❌ Harus reload aplikasi untuk melihat update

## ✅ Solusi - Enable Realtime di Supabase

### Langkah 1: Buka Supabase Dashboard

1. Login ke [supabase.com](https://supabase.com)
2. Pilih project Anda
3. Klik **"SQL Editor"** di sidebar kiri

### Langkah 2: Jalankan SQL Script

Copy dan paste SQL berikut ke SQL Editor, lalu klik **"Run"**:

```sql
-- Enable realtime for posts table
ALTER PUBLICATION supabase_realtime ADD TABLE posts;

-- Enable realtime for reels table
ALTER PUBLICATION supabase_realtime ADD TABLE reels;

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for notifications table  
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
```

### Langkah 3: Verifikasi

Jalankan query ini untuk verify realtime sudah enabled:

```sql
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;
```

Harusnya muncul list table:
- ✅ posts
- ✅ reels
- ✅ messages
- ✅ notifications

### Langkah 4: Restart Aplikasi Flutter

Setelah enable realtime di Supabase:
```bash
# Stop aplikasi (tekan 'q' di terminal)
# Lalu jalankan lagi
flutter run
```

## 📱 Cara Test Real-Time Setelah Enable

### Test 1: Posts Real-Time
1. Buka app di 2 device berbeda (User A & User B)
2. User A buat post baru
3. **User B harus langsung melihat post muncul di feed tanpa reload**
4. Log console akan muncul: `📮 New post detected: [post_id]`

### Test 2: Reels Real-Time
1. User A upload reel baru
2. **User B langsung lihat reel baru di reels page**
3. Notifikasi snackbar muncul: "🎥 New reel from @username"
4. Log console: `🎥 New reel detected: [reel_id]`

### Test 3: Messages Real-Time
1. User A kirim message ke User B
2. **Pop-up notification muncul di layar User B**
3. Notification snackbar dengan avatar sender
4. Log console: `💬 New incoming message received!`

### Test 4: Notifications Real-Time
1. User A like/comment post User B
2. **Notifikasi langsung muncul di User B**
3. Badge counter update otomatis
4. Log console: `🔔 New notification received`

## 🔍 Debug Jika Masih Tidak Bekerja

### Check 1: Console Logs

Setelah enable realtime, console harus menunjukkan:

```
✅ Real-time subscriptions setup completed
📮 New post detected: [id]
💬 New incoming message received!
🎥 New reel detected: [id]
```

### Check 2: Supabase Dashboard

Pergi ke **Database > Replication** di Supabase Dashboard:
- Pastikan "Enable Realtime" toggle ON untuk:
  - posts
  - reels  
  - messages
  - notifications

### Check 3: RLS Policies

Pastikan ada SELECT policy untuk table:

```sql
-- Check policies
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public';
```

## 📋 Alternative: Enable via Dashboard UI

Jika SQL tidak berhasil, enable via UI:

1. **Database → Replication** di sidebar
2. Cari table "posts"
3. Toggle **"Enable realtime"** ke ON
4. Ulangi untuk table: reels, messages, notifications

## 🎯 Expected Behavior Setelah Enable

### ✅ Posts
- Post baru langsung muncul di feed
- Tidak perlu pull-to-refresh
- Snackbar: "📮 New post from @username"

### ✅ Reels
- Reel baru langsung ada di reels page
- Likes update real-time
- Snackbar: "🎥 New reel from @username"

### ✅ Messages
- **Pop-up notification** muncul di atas
- Avatar sender + preview message
- Tombol "Reply" untuk langsung ke chat
- Duration 5 detik, auto-dismiss

### ✅ Notifications
- Badge counter update otomatis
- Snackbar dengan action "View"
- Jenis: follow, like, comment, message

## ⚡ Performance

Dengan real-time enabled:
- 🚀 Instant updates (< 1 detik)
- 📱 Data efficient (hanya kirim changes)
- 🔋 Battery friendly (WebSocket persistent connection)
- 🌐 Works across all devices

## 🆘 Troubleshooting

### Problem: Masih harus reload
**Solution**: 
- Pastikan SQL script sudah dijalankan
- Restart aplikasi Flutter
- Check Supabase logs di Dashboard

### Problem: Console menunjukkan error
**Solution**:
- Check internet connection
- Verify Supabase API key
- Check RLS policies

### Problem: Hanya bekerja untuk beberapa table
**Solution**:
- Enable realtime untuk SEMUA table yang diperlukan
- Jalankan SQL script lengkap

## 📞 Support

Jika masih ada masalah setelah enable realtime:
1. Check console logs
2. Check Supabase Dashboard logs
3. Verify table names match exactly
4. Ensure Flutter app reconnects after enabling realtime

---

**PENTING:** Realtime HARUS di-enable di Supabase Dashboard untuk fitur ini bekerja! Code Flutter sudah benar, hanya perlu enable di server side.
