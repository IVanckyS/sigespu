INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'director@lota.cl',
  'Director Seguridad Pública',
  '$2b$12$9askwZyhIVcL.FHnfbEIhekCptnOgaGQNNX2cA90dCsLikAhCv9g6',
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;

INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'admin@lota.cl',
  'Administrador del Sistema',
  '$2b$12$9askwZyhIVcL.FHnfbEIhekCptnOgaGQNNX2cA90dCsLikAhCv9g6',
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
