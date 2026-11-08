-- Jídelníček: tabulky a pravidla přístupu
-- Patří do Supabase projektu Rozcestníku (unoefgbzymlwwehgzusf), migrace jidelnicek_tabulky.
-- Funkce je_clen() a moje_jmeno() a tabulka clenove pochází z Rozcestníku.
-- Kdo je kdy doma, čte stránka z tabulek Plánovače (plan_volno, plan_svatky, plan_nastaveni).

-- ── Recepty ──
-- typ: vareni = plné vaření, rychlovka = pomazánka / chleba / něco studeného,
--      mrazak = ohřát ze zásob v mražáku, objednavka = jídlo zvenku
create table public.jid_recepty (
  id bigint generated always as identity primary key,
  nazev text not null,
  typ text not null default 'vareni' check (typ in ('vareni','rychlovka','mrazak','objednavka')),
  porce int not null default 3 check (porce between 1 and 20),
  cas_min int check (cas_min between 0 and 1440),
  stitky text[] not null default '{}',
  postup text not null default '',
  odkaz text not null default '',
  aktivni boolean not null default true,
  pridal text, vytvoreno timestamptz default now(),
  upravil text, upraveno timestamptz
);

-- suroviny receptu (množství na recept.porce porcí); oddeleni = oddělení v obchodě
create table public.jid_suroviny (
  id bigint generated always as identity primary key,
  recept_id bigint not null references public.jid_recepty(id) on delete cascade,
  nazev text not null,
  mnozstvi numeric,
  jednotka text not null default '',
  oddeleni text not null default 'ostatni'
    check (oddeleni in ('zelenina','maso','mlecne','pecivo','trvanlive','koreni','mrazene','napoje','ostatni')),
  poradi int not null default 0
);
create index jid_suroviny_recept_id on public.jid_suroviny(recept_id);

-- ── Den: ruční přepis automatiky ──
-- chod null = automaticky (oběd, když jsou přes den doma aspoň 2 z Jana/Lukáš/Jakub, jinak večeře)
-- porce null = automaticky (kolik z nich ten den není pryč)
-- vybrany_kandidat_id = ruční výběr místo vítěze hlasování
-- objednavka = „dnes si objednáme" – nic se nevaří ani nenakupuje
create table public.jid_dny (
  datum date primary key,
  chod text check (chod in ('obed','vecere','nic')),
  porce int check (porce between 1 and 20),
  vybrany_kandidat_id bigint,
  objednavka boolean not null default false,
  poznamka text not null default '',
  pridal text, vytvoreno timestamptz default now(),
  upravil text, upraveno timestamptz
);

-- ── Návrhy jídel ke dni a hlasování ──
create table public.jid_kandidati (
  id bigint generated always as identity primary key,
  datum date not null,
  recept_id bigint not null references public.jid_recepty(id) on delete cascade,
  navrhl text,
  vytvoreno timestamptz default now(),
  unique (datum, recept_id)
);
create index jid_kandidati_datum on public.jid_kandidati(datum);

alter table public.jid_dny add constraint jid_dny_vybrany_fk
  foreign key (vybrany_kandidat_id) references public.jid_kandidati(id) on delete set null;

create table public.jid_hlasy (
  kandidat_id bigint not null references public.jid_kandidati(id) on delete cascade,
  kdo text not null,
  hodnoceni int not null check (hodnoceni between 1 and 5),
  upraveno timestamptz default now(),
  primary key (kandidat_id, kdo)
);

-- ── Nákup ──
-- datum = den nákupu (den před jídlem); klic = automatická položka z receptů
-- (normalizovaný název|jednotka), u ručně přidané položky null
create table public.jid_nakup (
  id bigint generated always as identity primary key,
  datum date not null,
  klic text,
  text text not null default '',
  koupeno boolean not null default false,
  kdo text,
  upraveno timestamptz default now(),
  unique (datum, klic)
);
create index jid_nakup_datum on public.jid_nakup(datum);

-- „Mám doma" – základy, které se do nákupu nepřidávají (sůl, olej, rýže…)
create table public.jid_doma (
  id bigint generated always as identity primary key,
  nazev text not null unique
);

-- ── Kdo a kdy – plní server podle přihlášeného člena ──
create or replace function public.jid_audit() returns trigger
language plpgsql security definer set search_path to 'public' as $$
begin
  if tg_op = 'INSERT' then
    new.pridal    := coalesce(public.moje_jmeno(), new.pridal);
    new.vytvoreno := now();
    new.upravil   := null;
    new.upraveno  := null;
  else
    new.pridal    := old.pridal;
    new.vytvoreno := old.vytvoreno;
    new.upravil   := coalesce(public.moje_jmeno(), new.upravil);
    new.upraveno  := now();
  end if;
  return new;
end $$;
create trigger jid_recepty_audit before insert or update on public.jid_recepty for each row execute function public.jid_audit();
create trigger jid_dny_audit     before insert or update on public.jid_dny     for each row execute function public.jid_audit();

-- navrhl / kdo = přihlášený člen
create or replace function public.jid_kandidati_navrhl() returns trigger
language plpgsql security definer set search_path to 'public' as $$
begin
  new.navrhl := coalesce(public.moje_jmeno(), new.navrhl);
  return new;
end $$;
create trigger jid_kandidati_navrhl before insert on public.jid_kandidati for each row execute function public.jid_kandidati_navrhl();

create or replace function public.jid_nakup_kdo() returns trigger
language plpgsql security definer set search_path to 'public' as $$
begin
  new.kdo := coalesce(public.moje_jmeno(), new.kdo);
  new.upraveno := now();
  return new;
end $$;
create trigger jid_nakup_kdo before insert or update on public.jid_nakup for each row execute function public.jid_nakup_kdo();

-- hlas vždy patří přihlášenému – podvrhnout cizí hlas nejde
create or replace function public.jid_hlasy_kdo() returns trigger
language plpgsql security definer set search_path to 'public' as $$
begin
  if public.moje_jmeno() is not null then
    new.kdo := public.moje_jmeno();
  end if;
  if tg_op = 'UPDATE' and new.kdo is distinct from old.kdo then
    raise exception 'Cizí hlas měnit nelze';
  end if;
  new.upraveno := now();
  return new;
end $$;
create trigger jid_hlasy_kdo before insert or update on public.jid_hlasy for each row execute function public.jid_hlasy_kdo();

-- ── Row Level Security: jen členové rodiny ──
alter table public.jid_recepty   enable row level security;
alter table public.jid_suroviny  enable row level security;
alter table public.jid_dny       enable row level security;
alter table public.jid_kandidati enable row level security;
alter table public.jid_hlasy     enable row level security;
alter table public.jid_nakup     enable row level security;
alter table public.jid_doma      enable row level security;

create policy "jen rodina" on public.jid_recepty   for all to authenticated using (je_clen()) with check (je_clen());
create policy "jen rodina" on public.jid_suroviny  for all to authenticated using (je_clen()) with check (je_clen());
create policy "jen rodina" on public.jid_dny       for all to authenticated using (je_clen()) with check (je_clen());
create policy "jen rodina" on public.jid_kandidati for all to authenticated using (je_clen()) with check (je_clen());
create policy "jen rodina" on public.jid_nakup     for all to authenticated using (je_clen()) with check (je_clen());
create policy "jen rodina" on public.jid_doma      for all to authenticated using (je_clen()) with check (je_clen());
-- hlasy: číst smí celá rodina, měnit a mazat jen svůj
create policy "rodina cte"        on public.jid_hlasy for select to authenticated using (je_clen());
create policy "svuj hlas"         on public.jid_hlasy for insert to authenticated with check (je_clen());
create policy "svuj hlas uprava"  on public.jid_hlasy for update to authenticated using (je_clen() and kdo = moje_jmeno()) with check (je_clen());
create policy "svuj hlas smazani" on public.jid_hlasy for delete to authenticated using (je_clen() and kdo = moje_jmeno());
