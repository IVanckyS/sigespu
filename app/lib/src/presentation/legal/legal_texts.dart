// Textos legales embebidos — funcionan sin conexión a internet.
// Para actualizar: editar estas constantes y publicar nueva versión de la app.
// Versión 1.0 — Mayo 2026

abstract final class LegalTexts {
  static const String version = '1.0';
  static const String fecha = 'Mayo 2026';

  static const String terminos = '''
TÉRMINOS DE USO
SIGESPU — Sistema de Información Geoespacial de Seguridad Pública
Versión 1.0 — Mayo 2026

1. TITULARIDAD Y LICENCIA DE USO

SIGESPU fue desarrollado por Iván Salas como Práctica 2 (año 2026) y cedido en uso a la Ilustre Municipalidad de Lota, Dirección de Seguridad Pública, para fines de gestión pública interna. Los derechos de autor sobre el software corresponden a Iván Salas; la Municipalidad cuenta con una licencia de uso institucional no exclusiva para operar el sistema en el ámbito de sus funciones.

2. ACCESO Y ELEGIBILIDAD

El acceso a SIGESPU está restringido exclusivamente a funcionarios de la Ilustre Municipalidad de Lota que cuenten con una dirección de correo electrónico institucional del dominio @lota.cl o @munilota.cl. El registro implica que el funcionario actúa en el ejercicio de sus funciones y cuenta con autorización de su unidad.

Los niveles de acceso son:
— Visitante: lectura de capas del mapa y descarga de informes.
— Operativo: creación de reportes, elementos del mapa y zonas (requiere aprobación del Director).
— Director: administración de usuarios y solicitudes de acceso.

3. USO PERMITIDO

El uso de SIGESPU está autorizado exclusivamente para:
a) Consulta de capas de información geoespacial de la comuna de Lota.
b) Registro de reportes de incidentes de seguridad pública y emergencias urbanas en el ejercicio de funciones.
c) Agregar y gestionar elementos del mapa (puntos de interés, zonas, infraestructura) con fines operativos municipales.
d) Consulta de datos públicos recopilados del portal de transparencia municipal (lotatransparente.cl) conforme a la Ley N° 20.285.
e) Exportación de informes en PDF para uso interno institucional.

4. USO PROHIBIDO

Queda expresamente prohibido:
a) Acceder al sistema con credenciales ajenas o compartir credenciales de acceso con terceros.
b) Utilizar el sistema para fines distintos a los de la gestión pública municipal interna.
c) Realizar extracción masiva de datos (scraping, volcado de base de datos) sin autorización expresa de la Dirección de Seguridad Pública.
d) Publicar, difundir o ceder a terceros información confidencial obtenida a través del sistema.
e) Introducir datos falsos, inexactos o que no correspondan a hechos verificados en el ejercicio de funciones.
f) Intentar vulnerar la seguridad del sistema, incluyendo ataques de fuerza bruta, inyección de código u otras técnicas.

5. RESPONSABILIDAD DEL USUARIO

El funcionario es responsable de la veracidad, exactitud y pertinencia de la información que registre en el sistema. Los reportes de incidentes y elementos del mapa deben corresponder a hechos reales verificados en terreno. El uso indebido del sistema podrá dar lugar a acciones disciplinarias conforme al Estatuto Administrativo (Ley N° 18.834) y, en su caso, a responsabilidad civil o penal.

6. DATOS DE TERCEROS — SCRAPING DE LOTATRANSPARENTE.CL

Los datos de patentes comerciales, permisos de obras, decretos de tránsito y organizaciones sociales presentes en el sistema provienen de lotatransparente.cl, portal de transparencia activa de la Ilustre Municipalidad de Lota. Su publicación es de carácter obligatorio conforme a la Ley N° 20.285. El sistema SIGESPU los recopila, normaliza y georreferencia para facilitar la gestión interna; su uso queda restringido a los fines institucionales descritos en la cláusula 3.

7. DISPONIBILIDAD DEL SERVICIO

El sistema cuenta con modo sin conexión que permite operar sin internet en situaciones de emergencia, utilizando datos previamente sincronizados. La Dirección de Seguridad Pública no garantiza la disponibilidad ininterrumpida del servicio en línea y no será responsable de pérdidas de datos causadas por fallas de conectividad.

8. MODIFICACIONES AL SISTEMA Y A LOS TÉRMINOS

La Dirección de Seguridad Pública se reserva el derecho de modificar o descontinuar el sistema en cualquier momento. Las modificaciones a los presentes Términos de Uso entrarán en vigor con la publicación de la nueva versión del sistema. El uso continuado implica la aceptación de los términos actualizados.

9. LEGISLACIÓN APLICABLE Y JURISDICCIÓN

Los presentes Términos de Uso se rigen por la legislación vigente en la República de Chile. Para la resolución de cualquier controversia que pudiera surgir de su interpretación o aplicación, las partes se someten a la jurisdicción de los Tribunales de Justicia de la ciudad de Concepción, Región del Biobío, renunciando a cualquier otro fuero que pudiere corresponderles.''';

  static const String privacidad = '''
POLÍTICA DE PRIVACIDAD Y TRATAMIENTO DE DATOS PERSONALES
SIGESPU — Sistema de Información Geoespacial de Seguridad Pública
Versión 1.0 — Mayo 2026

RESPONSABLE DEL TRATAMIENTO
Dirección de Seguridad Pública
Ilustre Municipalidad de Lota
Pedro Aguirre Cerda 302, Lota, Región del Biobío, Chile
Contacto: contacto@munilota.cl

DESARROLLADOR DEL SOFTWARE
Iván Salas — Práctica 2, año 2026
El software fue desarrollado como práctica académica y cedido en uso a la Ilustre Municipalidad de Lota para fines de gestión pública interna.

1. OBJETO Y ÁMBITO DE APLICACIÓN

La presente Política de Privacidad regula el tratamiento de los datos personales de los funcionarios que utilizan SIGESPU en el ejercicio de sus funciones en la Dirección de Seguridad Pública de la Ilustre Municipalidad de Lota. El sistema es de uso interno exclusivo; no está destinado al público general.

2. MARCO NORMATIVO

El tratamiento de datos personales en SIGESPU se rige por:
— Ley N° 21.719, sobre Protección de Datos Personales (Chile)
— Ley N° 20.285, sobre Acceso a la Información Pública
— Ley N° 18.695, Orgánica Constitucional de Municipalidades
— Ley N° 21.180, de Transformación Digital del Estado
— Ley N° 21.663, sobre Datos Geoespaciales del Estado

3. DATOS PERSONALES TRATADOS Y FINALIDAD

3.1 Datos de registro y autenticación
— Nombre completo y correo electrónico institucional (@lota.cl o @munilota.cl): identificación del funcionario y control de acceso.
— Contraseña: almacenada únicamente como hash bcrypt de costo 12; no se almacena ni transmite en texto claro.
— Cargo y unidad municipal: asignación del nivel de acceso operativo.
— Fecha de aceptación de estos términos: cumplimiento normativo.

3.2 Datos de ubicación
El sistema solicita acceso a la ubicación GPS precisa del dispositivo exclusivamente cuando el funcionario agrega elementos al mapa o registra reportes de incidentes en terreno. La ubicación no se recopila en segundo plano ni fuera de estas acciones explícitas.

3.3 Fotografías
El sistema puede acceder a la cámara del dispositivo para adjuntar fotografías a reportes de incidentes de seguridad. Las fotografías se almacenan en los servidores del sistema y se vinculan al reporte correspondiente.

3.4 Datos geoespaciales operativos
Los puntos de interés, zonas de peligro, reportes de seguridad y demás elementos creados por el funcionario en ejercicio de sus funciones quedan registrados en la base de datos del sistema vinculados a la cuenta del funcionario que los creó.

3.5 Registro de auditoría (audit log)
En cumplimiento del artículo 14 de la Ley N° 21.719, el sistema mantiene un registro de las acciones realizadas por cada usuario, incluyendo dirección IP y agente de navegación o dispositivo.

4. PLAZO DE CONSERVACIÓN

Los datos del registro de auditoría se conservarán por un máximo de dos (2) años, conforme a lo dispuesto en la Ley N° 21.719. Los datos operativos permanecerán en el sistema mientras este esté activo y el funcionario mantenga su vínculo laboral con la institución. Los tokens de sesión se eliminan automáticamente al expirar: quince (15) minutos para el token de acceso; siete (7) a treinta (30) días para el token de refresco.

5. CESIÓN Y TRANSFERENCIA A TERCEROS

No se ceden datos personales a terceros con fines comerciales ni publicitarios. Los únicos servicios externos utilizados son:

— CartoDB/CARTO (tiles del mapa): recibe únicamente coordenadas de navegación cartográfica, sin datos personales identificativos.
— Servicio de correo electrónico: utilizado exclusivamente para el envío de códigos de verificación OTP y recuperación de contraseña. No conserva los datos enviados.
— Railway / Hetzner (infraestructura de servidores): procesador de datos bajo contrato de servicio; los datos se almacenan en servidores con sede en la Unión Europea.
— Cloudflare (CDN y protección anti-DDoS): actúa como intermediario de red; no accede al contenido de las solicitudes autenticadas.

6. DERECHOS DEL TITULAR

De conformidad con los artículos 22 a 29 de la Ley N° 21.719, el titular de los datos tiene derecho a:

a) Acceso: solicitar confirmación de qué datos personales son objeto de tratamiento.
b) Rectificación: exigir la corrección de datos inexactos o incompletos.
c) Cancelación/Supresión: solicitar la eliminación de sus datos cuando no sean necesarios para la finalidad que justificó su tratamiento.
d) Oposición: oponerse al tratamiento en los casos previstos por la ley.

Para ejercer estos derechos, el funcionario deberá dirigirse por escrito a: contacto@munilota.cl, indicando su nombre completo, correo institucional y el derecho que desea ejercer.

7. SEGURIDAD DE LOS DATOS

El sistema implementa las siguientes medidas técnicas de seguridad:
— Cifrado de contraseñas mediante bcrypt (costo 12).
— Tokens JWT de corta duración (15 minutos) con rotación automática de tokens de refresco.
— Almacenamiento de credenciales en el sistema de almacenamiento seguro del dispositivo (Keychain en iOS, Keystore en Android, almacenamiento cifrado en Web).
— Comunicaciones cifradas mediante TLS/HTTPS.
— Limitación de intentos en todos los endpoints de autenticación (rate limiting).
— Revocación inmediata de la familia completa de sesiones ante detección de reutilización de tokens de refresco.

8. MODIFICACIONES

La Dirección de Seguridad Pública se reserva el derecho de modificar esta Política de Privacidad. Las modificaciones entrarán en vigor con la publicación de la nueva versión del sistema. El uso continuado de SIGESPU tras la publicación implica la aceptación de los términos actualizados.''';
}
