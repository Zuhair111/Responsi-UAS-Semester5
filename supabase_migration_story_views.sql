-- Create story_views table to track who viewed which stories
CREATE TABLE IF NOT EXISTS public.story_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    story_id UUID NOT NULL REFERENCES public.stories(id) ON DELETE CASCADE,
    viewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(story_id, viewer_id)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_story_views_story_id ON public.story_views(story_id);
CREATE INDEX IF NOT EXISTS idx_story_views_viewer_id ON public.story_views(viewer_id);
CREATE INDEX IF NOT EXISTS idx_story_views_viewed_at ON public.story_views(viewed_at DESC);

-- Enable Row Level Security
ALTER TABLE public.story_views ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Users can view all story views (to check if story was viewed)
CREATE POLICY "Story views are viewable by everyone" ON public.story_views
    FOR SELECT
    USING (true);

-- Users can insert their own views
CREATE POLICY "Users can record their own views" ON public.story_views
    FOR INSERT
    WITH CHECK (auth.uid() = viewer_id);

-- Users can update their own views (for upsert operations)
CREATE POLICY "Users can update their own views" ON public.story_views
    FOR UPDATE
    USING (auth.uid() = viewer_id)
    WITH CHECK (auth.uid() = viewer_id);

-- Users can delete their own views (optional)
CREATE POLICY "Users can delete their own views" ON public.story_views
    FOR DELETE
    USING (auth.uid() = viewer_id);

-- Grant permissions
GRANT ALL ON public.story_views TO authenticated;
GRANT ALL ON public.story_views TO service_role;
