INSERT INTO usuarios (
  id, email, nombre, password_hash, nivel_acceso,
  solicitud_operativo, activo, created_at
) VALUES (
  uuid_generate_v4(),
  'director@lota.cl',
  'Director Seguridad Pública',
  '$2a$12$Vz7RTvLmIubAynwgWt8gjezaNiui8j21dLkxxt6BMXZjuZQY17QES', -- bcrypt de 'Admin2026!'
  'director',
  NULL,
  true,
  NOW()
) ON CONFLICT (email) DO NOTHING;
