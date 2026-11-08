#!/usr/bin/env python3
"""Vygeneruje SQL pro import receptů z JSON souboru do Supabase (tabulky jid_recepty, jid_suroviny).

Použití: python3 scripts/generuj_sql.py recepty-rodina.json sql/03_recepty_rodina.sql "popis"
Recept se stejným názvem, který už v databázi je, se přeskočí (import jde spustit opakovaně).
"""
import json, sys

def q(s):
    return "'" + str(s).replace("'", "''") + "'"

def num(x):
    return 'null' if x is None else str(x)

src, dst = sys.argv[1], sys.argv[2]
popis = sys.argv[3] if len(sys.argv) > 3 else src
R = json.load(open(src))
out = [f"-- Jídelníček: {popis}", f"-- Vygenerováno z {src} skriptem scripts/generuj_sql.py – needitovat ručně.",
       "-- Recepty se stejným názvem se přeskočí, takže skript jde spustit znovu.", "", "do $$", "declare rid bigint;", "begin"]
for r in R:
    st = "array[" + ",".join(q(t) for t in r['stitky']) + "]::text[]" if r['stitky'] else "'{}'::text[]"
    out.append(f"  if not exists (select 1 from public.jid_recepty where nazev = {q(r['nazev'])}) then")
    out.append(f"    insert into public.jid_recepty (nazev, typ, porce, cas_min, stitky, postup, odkaz) values ({q(r['nazev'])}, {q(r['typ'])}, {r['porce']}, {num(r.get('cas_min'))}, {st}, {q(r['postup'])}, {q(r.get('odkaz', ''))}) returning id into rid;")
    if r['suroviny']:
        vals = ", ".join(f"(rid, {q(n)}, {num(m)}, {q(j)}, {q(o)}, {i})" for i, (n, m, j, o) in enumerate(r['suroviny']))
        out.append(f"    insert into public.jid_suroviny (recept_id, nazev, mnozstvi, jednotka, oddeleni, poradi) values {vals};")
    out.append("  end if;")
out += ["end $$;", ""]
open(dst, 'w').write("\n".join(out))
print(f"{dst}: {len(R)} receptů")
