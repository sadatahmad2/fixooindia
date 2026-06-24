-- ============================================
-- FIXOO APP - SUPABASE DATABASE SCHEMA
-- ============================================
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================

-- 1. PROFILES TABLE (User data)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  email TEXT DEFAULT '',
  address TEXT DEFAULT '',
  city TEXT DEFAULT '',
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can only see and update their own profile
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  service_name TEXT NOT NULL,
  brand TEXT NOT NULL,
  problems TEXT[] NOT NULL DEFAULT '{}',
  scheduled_date TEXT NOT NULL,
  address TEXT DEFAULT 'Current Location',
  status TEXT NOT NULL DEFAULT 'Pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bookings" ON bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bookings" ON bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own bookings" ON bookings FOR UPDATE USING (auth.uid() = user_id);

-- 3. PRODUCTS TABLE (Buy section)
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  brand TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  old_price DECIMAL(10,2),
  category TEXT NOT NULL,
  rating DECIMAL(2,1) DEFAULT 4.0,
  image_url TEXT DEFAULT '',
  free_installation BOOLEAN DEFAULT true,
  in_stock BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Everyone can view products (public read)
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (true);

-- 4. ORDERS TABLE
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  free_installation BOOLEAN DEFAULT true,
  address TEXT DEFAULT 'Current Location',
  status TEXT NOT NULL DEFAULT 'Processing',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 5. WALLETS TABLE
CREATE TABLE IF NOT EXISTS wallets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) UNIQUE NOT NULL,
  balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wallet" ON wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own wallet" ON wallets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can create own wallet" ON wallets FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. TRANSACTIONS TABLE
CREATE TABLE IF NOT EXISTS transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- SEED DATA - Sample Products for Buy Section
-- ============================================
INSERT INTO products (name, brand, price, old_price, category, rating, free_installation) VALUES
-- AC
('Split AC 1.5 Ton', 'Voltas', 32990, 38990, 'AC', 4.3, true),
('Inverter AC 1 Ton', 'Daikin', 29490, 35000, 'AC', 4.5, true),
('Window AC 1.5 Ton', 'LG', 26990, 31000, 'AC', 4.2, true),
('Split AC 2 Ton', 'Samsung', 42990, 49990, 'AC', 4.4, true),
-- Fan
('Ceiling Fan 1200mm', 'Havells', 1899, 2499, 'Fan', 4.4, true),
('BLDC Fan 1200mm', 'Orient', 3499, 4299, 'Fan', 4.6, true),
('Exhaust Fan 12"', 'Crompton', 1099, 1399, 'Fan', 4.1, true),
('Decorative Fan', 'Bajaj', 2799, 3499, 'Fan', 4.3, true),
-- Cooler
('Desert Cooler 70L', 'Symphony', 9990, 12999, 'Cooler', 4.2, true),
('Tower Cooler 55L', 'Bajaj', 7490, 9999, 'Cooler', 4.0, true),
('Personal Cooler 30L', 'Kenstar', 4990, 6499, 'Cooler', 4.1, true),
-- TV
('Smart TV 43" 4K', 'Mi', 24999, 31999, 'TV', 4.4, true),
('LED TV 32" HD', 'Samsung', 13490, 17990, 'TV', 4.3, true),
('OLED TV 55"', 'LG', 89990, 109990, 'TV', 4.7, true),
-- Fridge
('Double Door 260L', 'Samsung', 23990, 28990, 'Fridge', 4.4, true),
('Single Door 190L', 'LG', 14490, 17990, 'Fridge', 4.3, true),
('Side by Side 650L', 'Whirlpool', 54990, 64990, 'Fridge', 4.5, true),
-- Washing Machine
('Front Load 7kg', 'IFB', 27990, 34990, 'Washing Machine', 4.5, true),
('Top Load 8kg', 'Whirlpool', 16990, 20990, 'Washing Machine', 4.2, true),
('Semi Auto 7.5kg', 'Samsung', 11990, 14990, 'Washing Machine', 4.0, true),
-- Water Purifier
('RO + UV Purifier', 'Kent', 15499, 19999, 'Water Purifier', 4.3, true),
('RO Purifier 8L', 'Aquaguard', 12999, 16999, 'Water Purifier', 4.1, true),
-- Light
('LED Bulb 12W (Pack 6)', 'Philips', 549, 799, 'Light', 4.5, true),
('Tube Light 20W', 'Syska', 349, 499, 'Light', 4.2, true),
('Panel Light 18W', 'Havells', 599, 899, 'Light', 4.3, true);
