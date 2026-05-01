-- Pointify Database Schema
-- Synced across Web, iOS, and Android

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone TEXT UNIQUE,
    nickname TEXT,
    name TEXT,
    avatar_url TEXT,
    country_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Point types enum
CREATE TYPE point_type AS ENUM ('social', 'commercial', 'info', 'event');

-- Points table (geo-tagged locations)
CREATE TABLE public.points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    type point_type DEFAULT 'social',
    type_name TEXT,
    beacon_id TEXT,
    creator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    posts_count INT DEFAULT 0,
    events_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Posts table (content attached to points)
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    point_id UUID REFERENCES public.points(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    header TEXT,
    body TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events table (time-bound happenings at points)
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    point_id UUID REFERENCES public.points(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    info TEXT,
    image_url TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Follows table (user connections)
CREATE TABLE public.follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    followed_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    notifications_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, followed_id)
);

-- Visits table (user check-ins at points)
CREATE TABLE public.visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    point_id UUID REFERENCES public.points(id) ON DELETE CASCADE,
    visited_at TIMESTAMPTZ DEFAULT NOW()
);

-- Device registrations for push notifications
CREATE TABLE public.devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform TEXT CHECK (platform IN ('ios', 'android', 'web')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, device_token)
);

-- Indexes for performance
CREATE INDEX idx_points_location ON public.points(lat, lon);
CREATE INDEX idx_points_creator ON public.points(creator_id);
CREATE INDEX idx_posts_point ON public.posts(point_id);
CREATE INDEX idx_posts_creator ON public.posts(creator_id);
CREATE INDEX idx_events_point ON public.events(point_id);
CREATE INDEX idx_events_dates ON public.events(start_date, end_date);
CREATE INDEX idx_follows_follower ON public.follows(follower_id);
CREATE INDEX idx_follows_followed ON public.follows(followed_id);
CREATE INDEX idx_visits_user ON public.visits(user_id);
CREATE INDEX idx_visits_point ON public.visits(point_id);

-- Function to update posts_count on points
CREATE OR REPLACE FUNCTION update_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.points SET posts_count = posts_count + 1 WHERE id = NEW.point_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.points SET posts_count = posts_count - 1 WHERE id = OLD.point_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_posts_count
AFTER INSERT OR DELETE ON public.posts
FOR EACH ROW EXECUTE FUNCTION update_posts_count();

-- Function to update events_count on points
CREATE OR REPLACE FUNCTION update_events_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.points SET events_count = events_count + 1 WHERE id = NEW.point_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.points SET events_count = events_count - 1 WHERE id = OLD.point_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_events_count
AFTER INSERT OR DELETE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_events_count();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_points_updated_at BEFORE UPDATE ON public.points FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_posts_updated_at BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Profiles viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Points policies
CREATE POLICY "Points viewable by everyone" ON public.points FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create points" ON public.points FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Creators can update own points" ON public.points FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Creators can delete own points" ON public.points FOR DELETE USING (auth.uid() = creator_id);

-- Posts policies
CREATE POLICY "Posts viewable by everyone" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Creators can update own posts" ON public.posts FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Creators can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = creator_id);

-- Events policies
CREATE POLICY "Events viewable by everyone" ON public.events FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create events" ON public.events FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Creators can update own events" ON public.events FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Creators can delete own events" ON public.events FOR DELETE USING (auth.uid() = creator_id);

-- Follows policies
CREATE POLICY "Follows viewable by everyone" ON public.follows FOR SELECT USING (true);
CREATE POLICY "Users can follow others" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- Visits policies
CREATE POLICY "Users can view own visits" ON public.visits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create visits" ON public.visits FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Devices policies
CREATE POLICY "Users can manage own devices" ON public.devices FOR ALL USING (auth.uid() = user_id);

-- Function to find nearby points (using simple distance calc)
CREATE OR REPLACE FUNCTION get_nearby_points(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    image_url TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    type point_type,
    creator_id UUID,
    posts_count INT,
    events_count INT,
    distance_km DOUBLE PRECISION,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.description,
        p.image_url,
        p.lat,
        p.lon,
        p.type,
        p.creator_id,
        p.posts_count,
        p.events_count,
        (6371 * acos(cos(radians(user_lat)) * cos(radians(p.lat)) * cos(radians(p.lon) - radians(user_lon)) + sin(radians(user_lat)) * sin(radians(p.lat)))) AS distance_km,
        p.created_at
    FROM public.points p
    WHERE (6371 * acos(cos(radians(user_lat)) * cos(radians(p.lat)) * cos(radians(p.lon) - radians(user_lon)) + sin(radians(user_lat)) * sin(radians(p.lat)))) <= radius_km
    ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;
