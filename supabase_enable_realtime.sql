-- ================================================
-- ENABLE REALTIME FOR ALL TABLES
-- ================================================
-- Run this in Supabase SQL Editor to enable real-time

-- Enable realtime for posts table
ALTER PUBLICATION supabase_realtime ADD TABLE posts;

-- Enable realtime for reels table
ALTER PUBLICATION supabase_realtime ADD TABLE reels;

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable realtime for notifications table  
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Enable realtime for stories table (optional)
ALTER PUBLICATION supabase_realtime ADD TABLE stories;

-- Enable realtime for comments table (optional)
ALTER PUBLICATION supabase_realtime ADD TABLE comments;

-- Enable realtime for reel_comments table (optional)
ALTER PUBLICATION supabase_realtime ADD TABLE reel_comments;

-- Enable realtime for likes table (optional)
ALTER PUBLICATION supabase_realtime ADD TABLE likes;

-- Verify realtime is enabled
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;
