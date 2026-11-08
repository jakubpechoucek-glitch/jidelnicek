-- Jídelníček: pomocná jídla (rychlovky, mražák, objednávka)
-- Vygenerováno z recepty-vychozi.json skriptem scripts/generuj_sql.py – needitovat ručně.
-- Recepty se stejným názvem se přeskočí, takže skript jde spustit znovu.

do $$
declare rid bigint;
begin
  if not exists (select 1 from public.jid_recepty where nazev = 'Tuňáková pomazánka') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Tuňáková pomazánka', 'rychlovka', 3, 10, array['ryba','studené']::text[], 'Tuňáka smíchat s lučinou, cibulkou a citronem. Na chléb nebo bagety s rajčaty.', '') returning id into rid;
    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values (rid, 'tuňák v konzervě', 2, 'plechovka', 'trvanlive', 0), (rid, 'krémový sýr', 200, 'g', 'mlecne', 1), (rid, 'jarní cibulka', 1, 'svazek', 'zelenina', 2), (rid, 'bageta', 2, 'ks', 'pecivo', 3), (rid, 'rajčata', 3, 'ks', 'zelenina', 4);
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Toasty se šunkou a sýrem') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Toasty se šunkou a sýrem', 'rychlovka', 3, 15, array['studené']::text[], 'Toastový chléb se šunkou a sýrem zapéct v toastovači, přidat zeleninu.', '') returning id into rid;
    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values (rid, 'toastový chléb', 1, 'balení', 'pecivo', 0), (rid, 'šunka', 200, 'g', 'maso', 1), (rid, 'sýr eidam plátky', 200, 'g', 'mlecne', 2), (rid, 'rajčata', 2, 'ks', 'zelenina', 3);
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Řecký salát s pitou') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Řecký salát s pitou', 'rychlovka', 3, 15, array['vege','studené']::text[], 'Nakrájet okurku, rajčata, papriku a cibuli, přidat olivy a fetu, zakápnout olejem. Podávat s ohřátou pitou.', '') returning id into rid;
    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values (rid, 'okurka salátová', 1, 'ks', 'zelenina', 0), (rid, 'rajčata', 3, 'ks', 'zelenina', 1), (rid, 'paprika', 1, 'ks', 'zelenina', 2), (rid, 'červená cibule', 1, 'ks', 'zelenina', 3), (rid, 'olivy', 1, 'sklenice', 'trvanlive', 4), (rid, 'feta', 200, 'g', 'mlecne', 5), (rid, 'pita', 1, 'balení', 'pecivo', 6);
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Guláš z mražáku') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Guláš z mražáku', 'mrazak', 3, 20, array['hovězí']::text[], 'Den předem přendat z mražáku do lednice, ohřát. Chleba koupit čerstvý.', '') returning id into rid;
    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values (rid, 'chléb', 1, 'ks', 'pecivo', 0);
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Polévka z mražáku') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Polévka z mražáku', 'mrazak', 3, 15, array['polévka']::text[], 'Ráno vyndat z mražáku, večer ohřát.', '') returning id into rid;
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Mražená pizza') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Mražená pizza', 'mrazak', 3, 20, '{}'::text[], 'Péct podle návodu na obalu.', '') returning id into rid;
    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values (rid, 'mražená pizza', 2, 'ks', 'mrazene', 0);
  end if;
  if not exists (select 1 from public.jid_recepty where nazev = 'Objednáme (Grab / Foodpanda)') then
    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ('Objednáme (Grab / Foodpanda)', 'objednavka', 3, 0, '{}'::text[], 'Nevaří se, objedná se jídlo.', '') returning id into rid;
  end if;
end $$;
insert into public.jid_doma (nazev) values
 ('sůl'), ('pepř'), ('olej'), ('cukr'), ('mouka'), ('ocet'), ('rýže'), ('sójová omáčka')
on conflict (nazev) do nothing;
