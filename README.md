# jidelnicek — rodinný jídelníček

Týdenní jídelníček rodiny s hlasováním a nákupem na den předem. Ve všední dny se vaří večeře, a když jsou přes den doma aspoň dva (víkend, svátek, prázdniny), vaří se oběd. Jana, Lukáš a Jakub hodnotí návrhy jídel hvězdičkami. Jídlo s nejvíc hvězdičkami vyhrává a jeho suroviny se hned objeví v nákupním seznamu na den předem.

- **Web:** https://jakubpechoucek-glitch.github.io/jidelnicek/
- **Ukázka bez přihlášení:** https://jakubpechoucek-glitch.github.io/jidelnicek/?demo (`&jako=Jana` nebo `&jako=Lukáš` ukáže pohled jiného člena)
- **Rozcestník (rodinný portál):** https://jakubpechoucek-glitch.github.io/rozcestnik/

## Co umí

| Záložka | Obsah |
|---|---|
| **Hlasování** | Jeden týden, výchozí je **příští týden** (šipkami se přepíná až na měsíc dopředu i zpět). Každý den má kartu se štítkem **☀️ Oběd / 🌙 Večeře / Nevaří se**, počtem porcí, kolečky J/L/J (přeškrtnuté = není doma) a důvodem („přes den doma: Jana, Lukáš, Jakub“). Pod tím **návrhy jídel**. U každého je 1–5 ★ pro přihlášeného (kliknutím na stejnou hvězdu se hlas zruší), hlasy ostatních, součet hvězd, doba přípravy a kdy jsme jídlo měli naposledy. Vedoucí návrh je zeleně. **Vybrat** zvolí jídlo ručně bez ohledu na hlasy (**Zrušit výběr** to vrátí hlasování). **+ Navrhnout jídlo** otevře výběr receptu (seřazené od těch, které jsme neměli nejdéle) nebo založení nového. **🛵 Objednáme** označí den jako objednávku zvenku, takže se nic nevaří ani nekupuje. Jde to kdykoli, i když už je odhlasováno. **⚙︎ Upravit** přepíše oběd / večeři / nevaří se, počet porcí a poznámku. **✨ Navrhnout jídla** doplní do dnů bez návrhu 3 jídla. Nahoře je „👉 Čeká na tvůj hlas“ a záložka má oranžový odznak s počtem dnů příštího týdne, kde přihlášený ještě nehlasoval. |
| **Nákup** | **Na zítra:** co dnes koupit na zítřejší jídlo. Suroviny vítězného receptu jsou přepočtené na počet porcí a seřazené podle oddělení v obchodě, dají se odškrtávat. Pod nimi jsou ručně přidané položky („✍️ Navíc“). Šipkami jde nákup posouvat po dnech. U jídla z mražáku je připomínka přendat ho večer do lednice. **Na 7 dní:** všechno na příští týden sečtené dohromady, u položky dny, kdy je potřeba (na velký nákup trvanlivých věcí). Dole je seznam **🏠 Mám doma**: základy (sůl, olej, rýže…), které se do nákupu nepřidávají. |
| **Měsíc** | 5 týdnů od tohoto pondělí. U každého dne je ☀️/🌙, vítězné jídlo, nebo ❓ s počtem návrhů. Oranžová tečka znamená, že na přihlášeného čeká hlas. Klepnutím na den se přejde na hlasování v daném týdnu. |
| **Recepty** | Databáze receptů s filtrem podle typu a hledáním podle názvu, štítku i suroviny. Detail ukazuje suroviny přepočítané na zvolený počet porcí (🏠 = máme doma), postup a odkaz. Recepty jdou upravit a archivovat (archivovaný se nenabízí, ale historie zůstává). **📋 Vložit z textu** převede zkopírovaný recept (např. ze Samsung Notes) na formulář ke kontrole. |

### Typy jídel

| Typ | Kdy | Nákup |
|---|---|---|
| 🍳 **Vaření** | plné vaření | suroviny z receptu |
| 🥪 **Rychlovka** | pomazánka, chleba, salát – když se nechce vařit | pár surovin |
| 🧊 **Z mražáku** | ohřát zásobu (polévka, guláš…) | obvykle nic, jen pečivo apod. |
| 🛵 **Objednávka** | jídlo zvenku | nic |

### Pravidla výpočtu

- **Kdo je doma** se bere z tabulek **Plánovače** (`plan_volno`, `plan_svatky`, `plan_nastaveni`) podle stejných pravidel. Přes den doma je ten, kdo má volno (víkend, filipínský svátek, zapsané volno, Jakub od `jakub_volno_od`) a není pryč. Pryč je ten, kdo má služební (`sluzebni`) nebo soukromou (`cesta`) cestu. `vyuka` znamená školu / práci i přes svátek.
- **Oběd nebo večeře:** když jsou přes den doma **aspoň 2** z Jany, Lukáše a Jakuba, vaří se **oběd**. Jinak se vaří **večeře** pro ty, kdo nejsou pryč. Když je doma jen jeden (nebo nikdo), **nevaří se**. U dne jde vše přepsat ručně (`jid_dny.chod`).
- **Porce** = kolik lidí jí: u oběda ti, kdo jsou přes den doma, u večeře ti, kdo nejsou pryč. Jde přepsat (`jid_dny.porce`).
- **Vítěz dne:** ručně vybraný návrh (`vybrany_kandidat_id`), jinak nejvyšší **součet hvězd**. Při shodě rozhoduje víc hlasujících, pak jídlo, které jsme měli nejdávněji, pak dřív navržené. Návrh bez hlasů nevyhrává. Den s 🛵 objednávkou vítěze nemá.
- **Nákup na den D** = suroviny vítěze dne D+1 × (porce dne / porce receptu), bez položek z „Mám doma“ (shoda názvu bez ohledu na velikost písmen a diakritiku). Stejné suroviny se stejnou jednotkou se sčítají. Zaokrouhlení: g/ml na celé (nad 100 na desítky), kusy na půlky, stroužky / plechovky / balení nahoru na celé.
- **Odškrtnutí** se ukládá k nákupnímu dni (`jid_nakup.datum`) a klíči suroviny. Když se vítěz změní, odškrtnutí nesouvisejících surovin nevadí.
- **Automatický návrh** dá do každého budoucího dne bez návrhu 3 jídla. Ve všední večer je jedno z nich rychlovka nebo mražák. Přednost mají jídla, která v posledních 14 dnech nevyhrála (`NEOPAKOVAT_DNI`) a nejsou už v tomtéž týdnu. Když recepty nestačí, vezme i nedávná.
- **Hlasy** počítají jen Jana, Lukáš a Jakub. Matěj nebo jiný člen se může přihlásit a dívat se, ale u hvězd nemá tlačítka.

### Vložení receptu z textu (Samsung Notes)

V poznámce označit vše → Kopírovat. Na webu v záložce Recepty → **📋 Vložit z textu** → vložit → **Pokračovat** otevře formulář ke kontrole. Rozpozná se:

- první řádek = **název**
- „4 porce“, „pro 4 osoby“ = **porce**; „90 min“ = **čas**
- řádky pod nadpisem „Suroviny / Ingredience“ nebo řádky začínající odrážkou či číslem = **suroviny** (`500 g kuřecí prsa`, `- 2 lžíce papriky`, `kuřecí stehna 800 g`, `1/2 lžičky kmínu`, `5 dkg sádla` → 50 g, `2 dl smetany` → 200 ml)
- řádky pod „Postup / Příprava“ a ostatní text = **postup**
- oddělení v obchodě se odhadne podle názvu suroviny (jde změnit)
- odkaz v textu → pole Odkaz

Suroviny jdou do existujícího receptu doplnit i tlačítkem **Vložit jako text…** ve formuláři.

## Jak to funguje

- Celá aplikace je v jediném souboru `index.html` (HTML + CSS + JS), bez buildu a bez závislostí kromě Supabase klienta z Rozcestníku.
- Hostuje se na **GitHub Pages**: push do `main` se rovnou nasadí.
- Poslední otevřená záložka se pamatuje v prohlížeči (`localStorage`, klíč `jidelnicek-view`).
- `?demo` načte `recepty-rodina.json` + `recepty-vychozi.json` a smyšlený týden (Jana na služební cestě, Lukáš ve středu bez školy, v pátek objednávka). Nic se neukládá.

### Přihlášení

- Stránka je za společným přihlášením rodiny z repa [`rozcestnik`](https://github.com/jakubpechoucek-glitch/rozcestnik) (Supabase), stejně jako Plánovač: `/rozcestnik/vendor/supabase-js-2.45.4.js` a `/rozcestnik/auth.js`, `RodinaAuth.vyzadujPrihlaseni()`.
- Kdo je přihlášený, se pozná z `moje_jmeno()` (tabulka `clenove`): podle křestního jména se přiřadí k Janě, Lukášovi nebo Jakubovi.

### Data (Supabase)

Projekt Rozcestníku (`unoefgbzymlwwehgzusf`). SQL se spouští v tomto pořadí:

1. [`sql/01_tabulky.sql`](sql/01_tabulky.sql) – tabulky, triggery, RLS
2. [`sql/02_vychozi_recepty.sql`](sql/02_vychozi_recepty.sql) – pomocná jídla (rychlovky, 🧊 z mražáku, 🛵 objednávka) a „Mám doma“, z `recepty-vychozi.json`
3. [`sql/03_recepty_rodina.sql`](sql/03_recepty_rodina.sql) – 49 rodinných receptů ze Samsung Notes, z `recepty-rodina.json`

Soubory 02 a 03 generuje `python3 scripts/generuj_sql.py <json> <sql> "<popis>"`. Recept, jehož název už v databázi je, se přeskočí, takže import jde spustit znovu.

**Rodinné recepty** (`recepty-rodina.json`) vznikly 8. 11. 2026 z exportu Samsung Notes (`~/Documents/recepty/*.docx`, 50 poznámek, „Creamy salmon pasta“ byla dvakrát). Poznámky byly hlavně screenshoty a náhledy odkazů. Text se přečetl přes OCR v macOS (Vision) a odkazy se dohledaly na webu. 35 receptů má kompletní suroviny. U 14 se recept na webu dohledat nepodařilo (BBC, Kaufland, Tesco, YouTube, share.google…). Ty mají jen název, odkaz a štítek **„doplnit suroviny“**: v záložce Recepty je najde hledání „doplnit“. Suroviny jde doplnit v ✎ Upravit (případně Vložit jako text).

| Tabulka | Obsah |
|---|---|
| `jid_recepty` | `nazev`, `typ` (`vareni`/`rychlovka`/`mrazak`/`objednavka`), `porce` (na kolik porcí jsou suroviny), `cas_min`, `stitky` (text[]), `postup`, `odkaz`, `aktivni` (false = archiv), plus kdo a kdy |
| `jid_suroviny` | `recept_id`, `nazev`, `mnozstvi` (může chybět), `jednotka`, `oddeleni` (`zelenina`, `maso`, `mlecne`, `pecivo`, `trvanlive`, `koreni`, `mrazene`, `napoje`, `ostatni`), `poradi` |
| `jid_dny` | `datum` (PK) a ruční přepis: `chod` (`obed`/`vecere`/`nic`, null = automaticky), `porce` (null = automaticky), `vybrany_kandidat_id`, `objednavka`, `poznamka` |
| `jid_kandidati` | návrh jídla ke dni: `datum`, `recept_id` (unikátní dvojice), `navrhl` (nastaví server) |
| `jid_hlasy` | `kandidat_id` + `kdo` (PK), `hodnoceni` 1–5 |
| `jid_nakup` | `datum` = nákupní den, `klic` (`název|jednotka` u položky z receptu, null u ručně přidané), `text`, `koupeno`, `kdo` |
| `jid_doma` | `nazev` – co máme vždycky doma |

- **Přístup:** RLS `je_clen()` jako u ostatních tabulek Rozcestníku. Navíc se čtou tabulky Plánovače `plan_*`. Když se nenačtou, stránka to napíše a počítá jen s víkendy.
- **Kdo a kdy:** `pridal`/`vytvoreno`/`upravil`/`upraveno` u receptů a dnů plní trigger `jid_audit()`, `navrhl` trigger `jid_kandidati_navrhl()`, `kdo` u nákupu trigger `jid_nakup_kdo()`.
- **Hlasy:** trigger `jid_hlasy_kdo()` vždy nastaví `kdo` na přihlášeného, takže hlasovat za jiného nejde. Číst smí celá rodina, měnit a mazat jen svůj.
- Stránka načítá návrhy, hlasy a dny 60 dní zpět (kvůli „naposledy“ a shodám) a nákup 7 dní zpět.

## Lokální náhled

```bash
python3 -m http.server 8768 --directory <složka se symlinky jidelnicek a rozcestnik>
```

Pak otevřít `http://localhost:8768/jidelnicek/?demo`. Bez `?demo` přihlášení na localhostu nefunguje (Supabase přesměrování je nastavené na GitHub Pages).

## Nápady na další verzi

- Evidence mražáku: „uvařit dvojitou porci → půlka do mražáku“, zásoby se pak nabízejí na dny typu 🧊.
- Claude jednou týdně navrhne 2–3 nová jídla podle toho, co rodině chutnalo.
- Hodnocení po jídle 👍/👎, které ovlivní automatické návrhy.
- Kdo vaří: přiřazení kuchaře ke dni.
- Upozornění na nevyvážený týden (3× kuře, žádná ryba).
