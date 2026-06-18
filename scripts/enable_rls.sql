-- Habilitar RLS en las tablas
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE tramites ENABLE ROW LEVEL SECURITY;

-- Permitir lectura anónima (para que la app pueda ver los datos)
CREATE POLICY "Allow public read categorias" ON categorias
  FOR SELECT USING (true);

CREATE POLICY "Allow public read tramites" ON tramites
  FOR SELECT USING (true);

-- Permitir escritura solo con service role (admin)
CREATE POLICY "Allow service role insert categorias" ON categorias
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Allow service role insert tramites" ON tramites
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Allow service role update categorias" ON categorias
  FOR UPDATE USING (auth.role() = 'service_role');

CREATE POLICY "Allow service role update tramites" ON tramites
  FOR UPDATE USING (auth.role() = 'service_role');
