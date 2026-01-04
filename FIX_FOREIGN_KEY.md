# 🔧 FIX: Foreign Key Relationship Missing

## ❌ Error yang Terjadi:
```
Could not find a relationship between 'posts' and 'profiles' in the schema cache
```

## ✅ Solusi: Tambah Foreign Key Constraint

Jalankan SQL ini di **Supabase Dashboard** → **SQL Editor**:

```sql
-- =============================================
-- FIX: Add Foreign Key Relationship
-- =============================================

-- 1. Drop existing foreign key if any (just in case)
ALTER TABLE posts 
DROP CONSTRAINT IF EXISTS posts_user_id_fkey;

-- 2. Add foreign key constraint
ALTER TABLE posts 
ADD CONSTRAINT posts_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES profiles(id) 
ON DELETE CASCADE;

-- 3. Create index for better performance
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);

-- 4. Verify relationship exists
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name='posts';
```

**Expected Output:**
```
table_name | column_name | foreign_table_name | foreign_column_name
-----------+-------------+--------------------+--------------------
posts      | user_id     | profiles           | id
```

## ✅ Setelah Jalankan SQL:

1. **Restart aplikasi** (full restart!)
2. **Login** lagi
3. **Buka Home Page**
4. **Posts harus muncul!** ✅

## 📊 Console Log Expected:

Setelah fix:
```
📥 Fetching posts from database...
📊 Limit: 20, Offset: 0
✅ Database response: 1 posts
✅ Posts parsed successfully: 1 posts
📝 First post: good
🖼️ First post image: https://zmpcueepuevlrkxjiork.supabase.co/...
```

## 🎉 Masalah Terselesaikan!

Foreign key akan membuat Supabase bisa join table `posts` dengan `profiles` otomatis!
