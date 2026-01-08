-- Add parent_comment_id field to comments table for reply functionality
-- Run this in Supabase SQL Editor

ALTER TABLE comments 
ADD COLUMN IF NOT EXISTS parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE;

-- Add foreign key constraint from comments to profiles
-- This enables joining comments with profiles using PostgREST
ALTER TABLE comments 
DROP CONSTRAINT IF EXISTS comments_user_id_fkey;

ALTER TABLE comments
ADD CONSTRAINT comments_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- Add index for better performance when fetching replies
CREATE INDEX IF NOT EXISTS idx_comments_parent ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
