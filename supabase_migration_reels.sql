-- Create reels table for video posts (max 10 seconds)

-- Create reels table
CREATE TABLE IF NOT EXISTS public.reels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  caption TEXT,
  duration INTEGER NOT NULL CHECK (duration <= 10), -- Max 10 seconds
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index for user_id
CREATE INDEX IF NOT EXISTS idx_reels_user_id ON public.reels(user_id);

-- Create index for created_at (for sorting)
CREATE INDEX IF NOT EXISTS idx_reels_created_at ON public.reels(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.reels ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all reels
CREATE POLICY "Users can view all reels"
  ON public.reels FOR SELECT
  USING (true);

-- Policy: Users can insert their own reels
CREATE POLICY "Users can insert their own reels"
  ON public.reels FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reels
CREATE POLICY "Users can update their own reels"
  ON public.reels FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own reels
CREATE POLICY "Users can delete their own reels"
  ON public.reels FOR DELETE
  USING (auth.uid() = user_id);

-- Create reel_likes table
CREATE TABLE IF NOT EXISTS public.reel_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reel_id UUID NOT NULL REFERENCES public.reels(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(reel_id, user_id)
);

-- Create index for reel_likes
CREATE INDEX IF NOT EXISTS idx_reel_likes_reel_id ON public.reel_likes(reel_id);
CREATE INDEX IF NOT EXISTS idx_reel_likes_user_id ON public.reel_likes(user_id);

-- Enable Row Level Security for reel_likes
ALTER TABLE public.reel_likes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all likes
CREATE POLICY "Users can view all reel likes"
  ON public.reel_likes FOR SELECT
  USING (true);

-- Policy: Users can insert their own likes
CREATE POLICY "Users can insert their own reel likes"
  ON public.reel_likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own likes
CREATE POLICY "Users can delete their own reel likes"
  ON public.reel_likes FOR DELETE
  USING (auth.uid() = user_id);

-- Create reel_views table
CREATE TABLE IF NOT EXISTS public.reel_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reel_id UUID NOT NULL REFERENCES public.reels(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(reel_id, user_id)
);

-- Create index for reel_views
CREATE INDEX IF NOT EXISTS idx_reel_views_reel_id ON public.reel_views(reel_id);

-- Enable Row Level Security for reel_views
ALTER TABLE public.reel_views ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all views
CREATE POLICY "Users can view all reel views"
  ON public.reel_views FOR SELECT
  USING (true);

-- Policy: Users can insert their own views
CREATE POLICY "Users can insert their own reel views"
  ON public.reel_views FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create function to update likes count
CREATE OR REPLACE FUNCTION update_reel_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.reels
    SET likes_count = likes_count + 1
    WHERE id = NEW.reel_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.reels
    SET likes_count = likes_count - 1
    WHERE id = OLD.reel_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for likes count
CREATE TRIGGER trigger_update_reel_likes_count
AFTER INSERT OR DELETE ON public.reel_likes
FOR EACH ROW
EXECUTE FUNCTION update_reel_likes_count();

-- Create function to update views count
CREATE OR REPLACE FUNCTION update_reel_views_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.reels
    SET views_count = views_count + 1
    WHERE id = NEW.reel_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for views count
CREATE TRIGGER trigger_update_reel_views_count
AFTER INSERT ON public.reel_views
FOR EACH ROW
EXECUTE FUNCTION update_reel_views_count();
