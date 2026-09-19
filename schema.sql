-- Jalankan di Supabase: SQL Editor -> New query -> Run
-- Login memakai Supabase Auth (email + password), tabel user sudah otomatis (auth.users)

-- 1. Daftar anggota kelompok (menu 1)
create table anggota (
  id bigint generated always as identity primary key,
  nama text not null,
  nim text not null,
  peran text
);

-- 2. Aturan hari baik (dipakai menu 2: komputasi) - data referensi
create table aturan_hari_baik (
  sisa int primary key,          -- hasil (total neptu) mod 8, sisa 0 dianggap 8
  nama text not null,
  baik boolean not null,
  arti text not null
);

-- 3. CRUD: data orang (nama + tanggal lahir + weton)
create table orang (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nama text not null,
  tanggal_lahir date not null,
  hari text not null,
  pasaran text not null,
  neptu int not null,
  created_at timestamptz not null default now()
);

-- 4. CRUD: rencana acara + hasil pengecekan hari baik
create table rencana_acara (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  orang_id uuid references orang(id) on delete set null,
  jenis_acara text not null,     -- nikah, pindah rumah, usaha, dll
  tanggal_acara date not null,
  hasil text,                    -- contoh: "Jodoh (baik)"
  catatan text,
  created_at timestamptz not null default now()
);

-- Keamanan: tiap user hanya melihat datanya sendiri
alter table orang enable row level security;
alter table rencana_acara enable row level security;
alter table anggota enable row level security;
alter table aturan_hari_baik enable row level security;

create policy "orang milik sendiri" on orang
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "acara milik sendiri" on rencana_acara
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "anggota bisa dibaca" on anggota
  for select using (auth.role() = 'authenticated');
create policy "aturan bisa dibaca" on aturan_hari_baik
  for select using (auth.role() = 'authenticated');

-- Data awal aturan (metode neptu mod 8, versi umum primbon)
insert into aturan_hari_baik (sisa, nama, baik, arti) values
  (1, 'Pegat',    false, 'Rawan perpisahan atau perselisihan'),
  (2, 'Ratu',     true,  'Dihormati, berwibawa'),
  (3, 'Jodoh',    true,  'Cocok, harmonis'),
  (4, 'Topo',     false, 'Banyak ujian di awal, perlu kesabaran'),
  (5, 'Tinari',   true,  'Mudah rezeki dan bahagia'),
  (6, 'Padu',     true,  'Ada perbedaan tapi bisa diselesaikan'),
  (7, 'Sujanan',  false, 'Rawan godaan atau masalah'),
  (8, 'Pesthi',   true,  'Tenteram dan sejahtera');

-- Data awal anggota (ganti dengan anggota kelompokmu)
insert into anggota (nama, nim, peran) values
  ('Justin Muhammad Rasyid', '124240074', 'Programmer'),
  ('Nama Anggota 2', 'NIM', 'Laporan'),
  ('Nama Anggota 3', 'NIM', 'Anggota');
