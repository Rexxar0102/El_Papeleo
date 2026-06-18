-- Actualizar tabla sugerencias con campos necesarios
-- Ejecutar en Supabase SQL Editor

-- Agregar columnas nuevas
ALTER TABLE sugerencias ADD COLUMN IF NOT EXISTS user_hash TEXT NOT NULL DEFAULT '';
ALTER TABLE sugerencias ADD COLUMN IF NOT EXISTS tipo TEXT NOT NULL DEFAULT 'mejora';
ALTER TABLE sugerencias ADD COLUMN IF NOT EXISTS titulo TEXT NOT NULL DEFAULT '';
ALTER TABLE sugerencias ADD COLUMN IF NOT EXISTS likes INTEGER DEFAULT 0;

-- Eliminar columnas innecesarias si existen
ALTER TABLE sugerencias DROP COLUMN IF EXISTS nombre_completo;

-- Habilitar RLS
ALTER TABLE sugerencias ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Allow public read sugerencias" ON sugerencias;
DROP POLICY IF EXISTS "Allow insert sugerencias" ON sugerencias;
DROP POLICY IF EXISTS "Allow update likes" ON sugerencias;

-- Permitir lectura pública (el foro es público)
CREATE POLICY "Allow public read sugerencias" ON sugerencias
  FOR SELECT USING (true);

-- Permitir inserción con service role (la app usa service_role key)
CREATE POLICY "Allow insert sugerencias" ON sugerencias
  FOR INSERT WITH CHECK (true);

-- Permitir actualizar likes
CREATE POLICY "Allow update likes" ON sugerencias
  FOR UPDATE USING (true);

-- Crear función para contar sugerencias por usuario
CREATE OR REPLACE FUNCTION count_sugerencias_by_user(p_user_hash TEXT)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER FROM sugerencias WHERE user_hash = p_user_hash;
$$ LANGUAGE sql SECURITY DEFINER;

-- Crear función para verificar límite de sugerencias
CREATE OR REPLACE FUNCTION can_create_sugerencia(p_user_hash TEXT)
RETURNS BOOLEAN AS $$
  SELECT count_sugerencias_by_user(p_user_hash) < 3;
$$ LANGUAGE sql SECURITY DEFINER;
