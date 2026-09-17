-- Create bookmarks table
CREATE TABLE IF NOT EXISTS public.bookmarks (
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    prompt_id uuid NOT NULL REFERENCES public.prompts(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (user_id, prompt_id)
);

-- Enable RLS
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Users can only read their own bookmarks
CREATE POLICY "Users can read their own bookmarks"
    ON public.bookmarks FOR SELECT
    USING (auth.uid() = user_id);

-- Users can only insert their own bookmarks
CREATE POLICY "Users can insert their own bookmarks"
    ON public.bookmarks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own bookmarks
CREATE POLICY "Users can delete their own bookmarks"
    ON public.bookmarks FOR DELETE
    USING (auth.uid() = user_id);

-- Create toggle_bookmark function
CREATE OR REPLACE FUNCTION public.toggle_bookmark(target_prompt_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    bookmark_exists boolean;
BEGIN
    -- Check if it already exists
    SELECT EXISTS (
        SELECT 1 FROM public.bookmarks
        WHERE user_id = auth.uid() AND prompt_id = target_prompt_id
    ) INTO bookmark_exists;

    IF bookmark_exists THEN
        -- Delete bookmark
        DELETE FROM public.bookmarks
        WHERE user_id = auth.uid() AND prompt_id = target_prompt_id;
        RETURN false; -- Meaning it is now NOT bookmarked
    ELSE
        -- Insert bookmark
        INSERT INTO public.bookmarks (user_id, prompt_id)
        VALUES (auth.uid(), target_prompt_id);
        RETURN true; -- Meaning it is now bookmarked
    END IF;
END;
$$;
