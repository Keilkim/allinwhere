-- ============================================================
-- Fix: handle_new_user 트리거 RLS 우회 보장
-- ============================================================

-- 1) 트리거 함수 재생성: search_path 명시 + SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2) 트리거가 없을 경우를 대비해 재생성
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3) 벨트-앤-서스펜더: profiles INSERT 정책 추가
-- (service_role이나 트리거에서도 안전하게 동작하도록)
DO $$ BEGIN
    CREATE POLICY "profiles_insert_own"
    ON profiles FOR INSERT
    TO authenticated
    WITH CHECK (id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 4) service_role도 profiles에 INSERT 가능하도록 GRANT
GRANT INSERT ON public.profiles TO service_role;
GRANT INSERT ON public.profiles TO authenticated;
