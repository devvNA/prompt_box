-- Migration: Profile Stats Feature
-- Creates likes, prompt_views tables and RPC functions for profile screen
-- Applied: 2026-09-16

-- ============================================================
-- 1. LIKES TABLE
-- Tracks which users liked which prompts (composite PK = unique like)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.likes (
  user_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prompt_id UUID NOT NULL REFERENCES public.prompts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, prompt_id)
);

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Likes are viewable by authenticated users"
  ON public.likes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can like prompts"
  ON public.likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike own likes"
  ON public.likes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ============================================================
-- 2. PROMPT_VIEWS TABLE
-- Tracks unique views per user per prompt (1 user = 1 view per prompt)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.prompt_views (
  user_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  prompt_id UUID NOT NULL REFERENCES public.prompts(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, prompt_id)
);

ALTER TABLE public.prompt_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Views are viewable by authenticated users"
  ON public.prompt_views FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can record own views"
  ON public.prompt_views FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);


-- ============================================================
-- 3. RPC: get_profile_stats
-- Returns aggregated profile data in a single call
-- Usage from Flutter: supabase.rpc('get_profile_stats', params: {'target_user_id': userId})
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_profile_stats(target_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_prompts',     (SELECT COUNT(*) FROM public.prompts WHERE owner_id = target_user_id),
    'total_likes',       (SELECT COUNT(*) FROM public.likes l
                          JOIN public.prompts p ON p.id = l.prompt_id
                          WHERE p.owner_id = target_user_id),
    'total_collections', (SELECT COUNT(*) FROM public.bookmarks WHERE user_id = target_user_id),
    'total_views',       (SELECT COUNT(*) FROM public.prompt_views pv
                          JOIN public.prompts p ON p.id = pv.prompt_id
                          WHERE p.owner_id = target_user_id),
    'username',          (SELECT username FROM public.profiles WHERE id = target_user_id),
    'avatar_url',        (SELECT avatar_url FROM public.profiles WHERE id = target_user_id),
    'bio',               (SELECT bio FROM public.profiles WHERE id = target_user_id),
    'created_at',        (SELECT created_at FROM public.profiles WHERE id = target_user_id)
  ) INTO result;

  RETURN result;
END;
$$;


-- ============================================================
-- 4. RPC: toggle_like
-- Toggle like/unlike on a prompt, returns is_liked + like_count
-- Usage from Flutter: supabase.rpc('toggle_like', params: {'target_prompt_id': promptId})
-- ============================================================
CREATE OR REPLACE FUNCTION public.toggle_like(target_prompt_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  is_liked BOOLEAN;
  like_count INT;
BEGIN
  IF EXISTS (SELECT 1 FROM public.likes WHERE user_id = auth.uid() AND prompt_id = target_prompt_id) THEN
    DELETE FROM public.likes WHERE user_id = auth.uid() AND prompt_id = target_prompt_id;
    is_liked := false;
  ELSE
    INSERT INTO public.likes (user_id, prompt_id) VALUES (auth.uid(), target_prompt_id);
    is_liked := true;
  END IF;

  SELECT COUNT(*) INTO like_count FROM public.likes WHERE prompt_id = target_prompt_id;

  RETURN json_build_object('is_liked', is_liked, 'like_count', like_count);
END;
$$;


-- ============================================================
-- 5. RPC: record_prompt_view
-- Records a unique view (idempotent via ON CONFLICT DO NOTHING)
-- Usage from Flutter: supabase.rpc('record_prompt_view', params: {'target_prompt_id': promptId})
-- ============================================================
CREATE OR REPLACE FUNCTION public.record_prompt_view(target_prompt_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.prompt_views (user_id, prompt_id)
  VALUES (auth.uid(), target_prompt_id)
  ON CONFLICT (user_id, prompt_id) DO NOTHING;
END;
$$;
