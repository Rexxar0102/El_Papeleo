-- Tabla de categorías
CREATE TABLE IF NOT EXISTS categorias (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  icono TEXT DEFAULT 'folder',
  color TEXT DEFAULT '#1F618D',
  orden INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de trámites
CREATE TABLE IF NOT EXISTS tramites (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  categoria_id TEXT REFERENCES categorias(id),
  descripcion TEXT,
  requisitos JSONB DEFAULT '[]',
  donde_hacerlo TEXT,
  horarios TEXT,
  costo_cup DECIMAL(10,2) DEFAULT 0,
  plazo_dias INTEGER DEFAULT 0,
  imagen_url TEXT,
  fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tramites_categoria ON tramites(categoria_id);
CREATE INDEX IF NOT EXISTS idx_tramites_nombre ON tramites(nombre);

-- Insertar categorías por defecto
INSERT INTO categorias (id, nombre, icono, color, orden) VALUES
  ('personas', 'Personas', 'person', '#1F618D', 1),
  ('negocios', 'Negocios', 'business', '#2E8B57', 2),
  ('vivienda', 'Vivienda', 'home', '#F4D03F', 3),
  ('trabajo', 'Trabajo', 'work', '#1F618D', 4),
  ('salud', 'Salud', 'health', '#C0392B', 5),
  ('educacion', 'Educación', 'school', '#2E8B57', 6)
ON CONFLICT (id) DO NOTHING;

-- Insertar trámites de ejemplo
INSERT INTO tramites (id, nombre, categoria_id, descripcion, requisitos, donde_hacerlo, horarios, costo_cup, plazo_dias) VALUES
  ('pasaporte', 'Solicitar Pasaporte', 'personas',
   'Trámite para obtener o renovar el pasaporte cubano. Es necesario presentar documentación personal y cumplir con los requisitos establecidos.',
   '["Carta de solicitud dirigida al director del DNMR","Certificado de antecedentes penales","Certificado de nacimiento","2 fotos tamaño carnet recientes","Constancia de residencia","Pago de la tasa correspondiente"]',
   'Dirección de Inmigración y Extranjería, Calle 17 entre K y L, Plaza de la Revolución',
   'Lunes a Viernes: 8:00 AM - 3:00 PM',
   200, 15),

  ('certificado-nacimiento', 'Certificado de Nacimiento', 'personas',
   'Certificado que acredita el nacimiento de una persona en territorio cubano. Necesario para trámites legales y administrativos.',
   '["Solicitud personal","Documento de identidad del solicitante","Libreta de familia (si aplica)"]',
   'Registro Civil del municipio correspondiente',
   'Lunes a Viernes: 8:00 AM - 4:00 PM',
   5, 3),

  ('licencia-conducir', 'Licencia de Conducir', 'personas',
   'Trámite para obtener o renovar la licencia de conducción vehicular.',
   '["Examen médico aprobado","Examen teórico aprobado","Examen práctico aprobado","Certificado de residencia","2 fotos tamaño carnet","Pago de tasas"]',
   'Centro de Automovilismo del municipio',
   'Lunes a Viernes: 7:00 AM - 3:00 PM',
   150, 20),

  ('tarjeta-identidad', 'Tarjeta de Identidad', 'personas',
   'Documento de identidad personal obligatorio para todos los ciudadanos mayores de 16 años.',
   '["Certificado de nacimiento","2 fotos tamaño carnet","Constancia de residencia","Carta del CDR"]',
   'Comisión de Identificación del municipio',
   'Lunes a Viernes: 8:00 AM - 3:00 PM',
   20, 10),

  ('certificado-vivienda', 'Certificado de Vivienda', 'vivienda',
   'Documento que certifica la dirección de residencia de una persona.',
   '["Solicitud personal","Documento de identidad","Constancia del CDR","Recibo de servicios básicos"]',
   'Dirección de Vivienda del municipio',
   'Lunes a Viernes: 8:00 AM - 12:00 PM',
   10, 5),

  ('registro-empresa', 'Registro de Empresa', 'negocios',
   'Trámite para registrar un nuevo negocio o empresa en Cuba.',
   '["Plan de negocio aprobado","Certificado de domicilio","Estatutos sociales","Capital social demostrado","Seguro de responsabilidad civil"]',
   'Registro Mercantil de la Cámara de Comercio',
   'Lunes a Viernes: 8:00 AM - 4:00 PM',
   500, 30),

  ('constancia-trabajo', 'Constancia de Trabajo', 'trabajo',
   'Documento que acredita la situación laboral de una persona.',
   '["Solicitud personal","Libreta de trabajo","Documento de identidad"]',
   'Departamento de Recursos Humanos del centro de trabajo',
   'Lunes a Viernes: 8:00 AM - 4:00 PM',
   0, 5),

  ('certificado-medico', 'Certificado Médico', 'salud',
   'Documento que certifica el estado de salud de una persona para fines laborales o legales.',
   '["Solicitud personal","Documento de identidad","Examen médico"]',
   'Consultorio del médico de la familia',
   'Lunes a Sábado: 7:00 AM - 12:00 PM',
   15, 3),

  ('constancia-estudio', 'Constancia de Estudio', 'educacion',
   'Documento que acredita la condición de estudiante.',
   '["Solicitud personal","Certificado de nacimiento","Libreta de calificaciones"]',
   'Secretaría de la escuela o universidad',
   'Lunes a Viernes: 8:00 AM - 4:00 PM',
   0, 3)
ON CONFLICT (id) DO NOTHING;
