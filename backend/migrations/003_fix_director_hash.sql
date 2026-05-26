UPDATE usuarios
SET password_hash = '$2b$12$9askwZyhIVcL.FHnfbEIhekCptnOgaGQNNX2cA90dCsLikAhCv9g6',
    updated_at = NOW()
WHERE email IN ('director@lota.cl', 'admin@lota.cl')
AND password_hash = '$2a$12$REEMPLAZAR_CON_HASH_BCRYPT_REAL_VER_DOCS';
