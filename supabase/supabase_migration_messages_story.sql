-- Add story fields to messages table

-- Add story_id column
ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS story_id UUID REFERENCES public.stories(id) ON DELETE SET NULL;

-- Add story_image_url column to store story preview
ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS story_image_url TEXT;

-- Create index for faster story message queries
CREATE INDEX IF NOT EXISTS idx_messages_story_id ON public.messages(story_id);

-- Update message_type check constraint if it exists
DO $$ 
BEGIN
  -- Drop existing constraint if it exists
  ALTER TABLE public.messages DROP CONSTRAINT IF EXISTS messages_message_type_check;
  
  -- Add updated constraint with 'story' type
  ALTER TABLE public.messages 
  ADD CONSTRAINT messages_message_type_check 
  CHECK (message_type IN ('text', 'image', 'post', 'story'));
EXCEPTION 
  WHEN duplicate_object THEN NULL;
END $$;
