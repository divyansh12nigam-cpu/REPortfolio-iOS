-- REPortfolio Supabase Setup
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor > New query)

-- 1. User properties (replaces UserDefaults as cloud source of truth)
CREATE TABLE IF NOT EXISTS user_properties (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_name TEXT NOT NULL,
    city TEXT NOT NULL,
    locality TEXT NOT NULL,
    area_sqft INT NOT NULL DEFAULT 0,
    purchase_price BIGINT NOT NULL DEFAULT 0,
    purchase_year INT NOT NULL DEFAULT 2024,
    monthly_rent INT NOT NULL DEFAULT 0,
    society_name TEXT NOT NULL DEFAULT '',
    floor_plan TEXT,
    custom_name TEXT NOT NULL DEFAULT '',
    purchase_month TEXT NOT NULL DEFAULT '',
    usage_type TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Shared valuation cache (cross-user, 30-day TTL enforced client-side)
CREATE TABLE IF NOT EXISTS valuation_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cache_key TEXT NOT NULL UNIQUE,
    society_name TEXT NOT NULL,
    city TEXT NOT NULL,
    locality TEXT NOT NULL,
    floor_plan TEXT,
    price_per_sqft DOUBLE PRECISION NOT NULL,
    value_low DOUBLE PRECISION NOT NULL,
    value_high DOUBLE PRECISION NOT NULL,
    fair_value DOUBLE PRECISION NOT NULL,
    source TEXT NOT NULL DEFAULT 'parsed',
    confidence TEXT NOT NULL DEFAULT 'medium',
    comparable_count INT NOT NULL DEFAULT 0,
    bhk_filtered BOOLEAN NOT NULL DEFAULT false,
    size_filtered BOOLEAN NOT NULL DEFAULT false,
    filter_fallback TEXT NOT NULL DEFAULT 'none',
    warnings JSONB NOT NULL DEFAULT '[]',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Row Level Security

-- user_properties: users can only CRUD their own rows
ALTER TABLE user_properties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users CRUD own properties" ON user_properties
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- valuation_cache: any authenticated user can read and write (shared cache)
ALTER TABLE valuation_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Auth users read cache" ON valuation_cache
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Auth users insert cache" ON valuation_cache
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Auth users update cache" ON valuation_cache
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- 4. Index for fast cache lookups
CREATE INDEX IF NOT EXISTS idx_valuation_cache_key ON valuation_cache(cache_key);
CREATE INDEX IF NOT EXISTS idx_user_properties_user ON user_properties(user_id, sort_order);
