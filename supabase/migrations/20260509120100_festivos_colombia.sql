-- =====================================================================
-- Festivos de Colombia (Ley Emiliani aplicada)
-- Tabla server-side mas funciones de calculo. La app Flutter replicara
-- el mismo algoritmo en Dart para operacion offline.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tabla cache de festivos
-- ---------------------------------------------------------------------
create table public.festivos_co (
  fecha   date primary key,
  nombre  text not null
);

-- Lectura libre, sin RLS (datos publicos no sensibles)
alter table public.festivos_co enable row level security;
create policy festivos_lectura on public.festivos_co
  for select using (true);

-- ---------------------------------------------------------------------
-- Funciones auxiliares
-- ---------------------------------------------------------------------

-- Calcula fecha de Pascua (Domingo de Resurreccion) por algoritmo de Gauss
create or replace function public.easter_date(p_year integer)
returns date
language plpgsql
immutable
as $$
declare
  a int; b int; c int; d int; e int; f int; g int;
  h int; i int; k int; l int; m int; mes int; dia int;
begin
  a := p_year % 19;
  b := p_year / 100;
  c := p_year % 100;
  d := b / 4;
  e := b % 4;
  f := (b + 8) / 25;
  g := (b - f + 1) / 3;
  h := (19 * a + b - d - g + 15) % 30;
  i := c / 4;
  k := c % 4;
  l := (32 + 2 * e + 2 * i - h - k) % 7;
  m := (a + 11 * h + 22 * l) / 451;
  mes := (h + l - 7 * m + 114) / 31;
  dia := ((h + l - 7 * m + 114) % 31) + 1;
  return make_date(p_year, mes, dia);
end;
$$;

-- Devuelve el lunes correspondiente segun Ley Emiliani:
-- si la fecha es lunes, queda igual; si no, retorna el siguiente lunes.
create or replace function public.next_monday(p_date date)
returns date
language sql
immutable
as $$
  select case extract(dow from p_date)::int
    when 1 then p_date
    when 0 then p_date + 1
    else p_date + (8 - extract(dow from p_date)::int)
  end;
$$;

-- Genera todos los festivos colombianos de un anio
create or replace function public.festivos_colombia(p_year integer)
returns table(fecha date, nombre text)
language plpgsql
immutable
as $$
declare
  pascua date := public.easter_date(p_year);
begin
  -- Fijos (no se mueven)
  return query select make_date(p_year, 1, 1),   'Ano Nuevo'::text;
  return query select make_date(p_year, 5, 1),   'Dia del Trabajo'::text;
  return query select make_date(p_year, 7, 20),  'Dia de la Independencia'::text;
  return query select make_date(p_year, 8, 7),   'Batalla de Boyaca'::text;
  return query select make_date(p_year, 12, 8),  'Inmaculada Concepcion'::text;
  return query select make_date(p_year, 12, 25), 'Navidad'::text;

  -- Moviles a lunes (Ley Emiliani)
  return query select public.next_monday(make_date(p_year, 1, 6)),   'Reyes Magos'::text;
  return query select public.next_monday(make_date(p_year, 3, 19)),  'San Jose'::text;
  return query select public.next_monday(make_date(p_year, 6, 29)),  'San Pedro y San Pablo'::text;
  return query select public.next_monday(make_date(p_year, 8, 15)),  'Asuncion de la Virgen'::text;
  return query select public.next_monday(make_date(p_year, 10, 12)), 'Dia de la Raza'::text;
  return query select public.next_monday(make_date(p_year, 11, 1)),  'Todos los Santos'::text;
  return query select public.next_monday(make_date(p_year, 11, 11)), 'Independencia de Cartagena'::text;

  -- Semana Santa (NO se mueven)
  return query select pascua - 3, 'Jueves Santo'::text;
  return query select pascua - 2, 'Viernes Santo'::text;

  -- Moviles desde Pascua, llevados a lunes
  return query select public.next_monday(pascua + 39), 'Ascension del Senor'::text;
  return query select public.next_monday(pascua + 60), 'Corpus Christi'::text;
  return query select public.next_monday(pascua + 68), 'Sagrado Corazon'::text;
end;
$$;

-- Pobla la tabla cache desde start_year hasta end_year
create or replace function public.poblar_festivos(start_year integer, end_year integer)
returns integer
language plpgsql
as $$
declare
  y          integer;
  insertados integer := 0;
  fila       record;
begin
  for y in start_year..end_year loop
    for fila in select * from public.festivos_colombia(y) loop
      insert into public.festivos_co(fecha, nombre)
        values (fila.fecha, fila.nombre)
        on conflict (fecha) do nothing;
      if found then
        insertados := insertados + 1;
      end if;
    end loop;
  end loop;
  return insertados;
end;
$$;

-- ¿Es dia habil en Colombia? (lunes-viernes excluyendo festivos)
create or replace function public.es_dia_habil(p_date date)
returns boolean
language sql
stable
as $$
  select extract(dow from p_date) between 1 and 5
    and not exists (
      select 1 from public.festivos_co where fecha = p_date
    );
$$;

-- Suma N dias habiles a una fecha
create or replace function public.sumar_dias_habiles(p_date date, p_dias integer)
returns date
language plpgsql
stable
as $$
declare
  cursor_fecha date := p_date;
  contados     integer := 0;
begin
  while contados < p_dias loop
    cursor_fecha := cursor_fecha + 1;
    if public.es_dia_habil(cursor_fecha) then
      contados := contados + 1;
    end if;
  end loop;
  return cursor_fecha;
end;
$$;

-- ---------------------------------------------------------------------
-- Carga inicial: 2024 a 2035
-- ---------------------------------------------------------------------
select public.poblar_festivos(2024, 2035);
