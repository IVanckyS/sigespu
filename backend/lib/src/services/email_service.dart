import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Envía correos usando la Gmail REST API (HTTPS) en lugar de SMTP.
/// Railway bloquea los puertos 25/465/587, pero HTTPS funciona normalmente.
///
/// Variables de entorno requeridas:
///   GMAIL_CLIENT_ID      — OAuth2 client ID de Google Cloud Console
///   GMAIL_CLIENT_SECRET  — OAuth2 client secret
///   GMAIL_REFRESH_TOKEN  — refresh token obtenido en el setup inicial
///   SMTP_USER            — dirección Gmail del remitente (sigespulota@gmail.com)
class EmailService {
  final String _clientId;
  final String _clientSecret;
  final String _refreshToken;
  final String _fromEmail;

  EmailService()
      : _clientId = Platform.environment['GMAIL_CLIENT_ID'] ?? '',
        _clientSecret = Platform.environment['GMAIL_CLIENT_SECRET'] ?? '',
        _refreshToken = Platform.environment['GMAIL_REFRESH_TOKEN'] ?? '',
        _fromEmail =
            Platform.environment['SMTP_USER'] ?? 'sigespulota@gmail.com';

  Future<String?> _getAccessToken() async {
    try {
      final response = await http
          .post(
            Uri.parse('https://oauth2.googleapis.com/token'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'client_id': _clientId,
              'client_secret': _clientSecret,
              'refresh_token': _refreshToken,
              'grant_type': 'refresh_token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['access_token'] as String?;
      }
      print(
          '[EmailService] Error obteniendo access token (${response.statusCode}): ${response.body}');
    } catch (e) {
      print('[EmailService] Error al obtener access token: $e');
    }
    return null;
  }

  Future<void> _send({
    required String toEmail,
    required String subject,
    required String html,
  }) async {
    if (_clientId.isEmpty || _refreshToken.isEmpty) {
      print('[EmailService] Gmail OAuth no configurado — correo omitido');
      return;
    }

    final accessToken = await _getAccessToken();
    if (accessToken == null) return;

    // RFC 2822 con subject en Base64 para soportar tildes/ñ/·
    final subjectEncoded =
        '=?UTF-8?B?${base64.encode(utf8.encode(subject))}?=';
    final raw = [
      'From: SIGESPU Lota <$_fromEmail>',
      'To: $toEmail',
      'Subject: $subjectEncoded',
      'MIME-Version: 1.0',
      'Content-Type: text/html; charset=UTF-8',
      '',
      html,
    ].join('\r\n');

    final encoded = base64Url.encode(utf8.encode(raw));

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://gmail.googleapis.com/gmail/v1/users/me/messages/send'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'raw': encoded}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print(
            '[EmailService] Gmail API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[EmailService] Error al enviar correo a $toEmail: $e');
    }
  }

  Future<void> sendVerificationCode(
      String toEmail, String nombre, String codigo) async {
    await _send(
      toEmail: toEmail,
      subject: 'Activa tu cuenta SIGESPU · Código de verificación',
      html: buildHtml(nombre, codigo),
    );
  }

  Future<void> sendPasswordResetCode(
      String toEmail, String nombre, String codigo) async {
    await _send(
      toEmail: toEmail,
      subject: 'Recuperar contraseña SIGESPU · Código de verificación',
      html: buildResetHtml(nombre, codigo),
    );
  }

  static String buildHtml(String nombre, String codigo) {
    final now = DateTime.now();
    final expira = now.add(const Duration(minutes: 15));
    final ref =
        'REF–${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final expiraStr =
        '${expira.day} de ${months[expira.month - 1]} de ${expira.year}, '
        '${expira.hour.toString().padLeft(2, '0')}:${expira.minute.toString().padLeft(2, '0')}';

    final codeBoxes = codigo.split('').map((d) => '''
      <td style="width:48px;height:56px;background:#F5EFE6;border:1.5px solid #E7DFD0;
        border-radius:10px;text-align:center;vertical-align:middle;
        font-family:'Courier New',Courier,monospace;font-size:24px;
        font-weight:700;color:#1C1917;">$d</td>
      <td style="width:8px;"></td>
    ''').join();

    return '''
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:32px;background:#E5E7EB;font-family:Arial,sans-serif;">
<div style="max-width:600px;margin:0 auto;background:#F5EFE6;border-radius:18px;border:1px solid #E7DFD0;overflow:hidden;">

  <div style="padding:20px 32px;border-bottom:1px solid #E7DFD0;">
    <table style="width:100%;border-spacing:0;"><tr>
      <td><div style="font-size:15px;font-weight:700;color:#1C1917;">SIGESPU</div>
          <div style="font-size:10px;color:#78716C;letter-spacing:0.18em;text-transform:uppercase;margin-top:2px;">Ilustre Municipalidad de Lota</div></td>
      <td style="text-align:right;"><span style="font-family:'Courier New',monospace;font-size:10px;color:#9A3412;background:#FFF7ED;padding:5px 10px;border-radius:6px;font-weight:600;border:1px solid #FED7AA;">$ref</span></td>
    </tr></table>
  </div>

  <div style="padding:40px 44px 28px;">
    <div style="font-size:10px;font-weight:700;letter-spacing:0.3em;text-transform:uppercase;color:#9A3412;margin-bottom:18px;">N° 001 · Activación de cuenta</div>
    <h1 style="font-size:44px;line-height:1;font-weight:700;letter-spacing:-0.03em;color:#1C1917;margin:0 0 18px 0;">
      Bienvenido,<br><span style="color:#EA580C;font-style:italic;font-weight:500;">$nombre</span>.
    </h1>
    <p style="font-size:15px;line-height:1.65;color:#44403C;margin:0;">
      Tu cuenta institucional en <strong style="color:#1C1917;">SIGESPU · Lota</strong> está lista.
      Ingresa el código de activación en la aplicación para completar tu registro.
    </p>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FFFEFB;border:1px solid #E7DFD0;border-radius:16px;padding:28px;">
      <div style="font-size:14px;font-weight:700;color:#1C1917;margin-bottom:4px;">Código de verificación</div>
      <div style="font-size:12px;color:#78716C;margin-bottom:18px;">Válido por <strong style="color:#9A3412;">15 minutos</strong>. No lo compartas con nadie.</div>
      <table style="border-spacing:0;border-collapse:separate;"><tr>$codeBoxes</tr></table>
      <div style="margin-top:14px;font-size:12px;color:#78716C;">
        Vence el <strong style="color:#1C1917;">$expiraStr</strong>
      </div>
    </div>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FFF7ED;border:1px solid #FED7AA;border-radius:12px;padding:14px 18px;font-size:12px;color:#7C2D12;line-height:1.55;">
      <strong>¿No solicitaste este acceso?</strong> Ignora este correo. Esta solicitud expirará automáticamente en 15 minutos.
    </div>
  </div>

  <div style="padding:22px 44px 26px;border-top:1px solid #E7DFD0;background:#EFE7DA;">
    <div style="font-size:11px;color:#78716C;line-height:1.7;">
      <strong style="font-size:12px;color:#1C1917;">Ilustre Municipalidad de Lota</strong><br>
      Dirección de Seguridad Pública · Aníbal Pinto 442, Lota · SIGESPU v1.0.0
    </div>
  </div>

</div>
</body>
</html>
''';
  }

  static String buildResetHtml(String nombre, String codigo) {
    final now = DateTime.now();
    final expira = now.add(const Duration(minutes: 15));
    final ref =
        'REF–${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final expiraStr =
        '${expira.day} de ${months[expira.month - 1]} de ${expira.year}, '
        '${expira.hour.toString().padLeft(2, '0')}:${expira.minute.toString().padLeft(2, '0')}';

    final codeBoxes = codigo.split('').map((d) => '''
      <td style="width:48px;height:56px;background:#F5EFE6;border:1.5px solid #E7DFD0;
        border-radius:10px;text-align:center;vertical-align:middle;
        font-family:'Courier New',Courier,monospace;font-size:24px;
        font-weight:700;color:#1C1917;">$d</td>
      <td style="width:8px;"></td>
    ''').join();

    return '''
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:32px;background:#E5E7EB;font-family:Arial,sans-serif;">
<div style="max-width:600px;margin:0 auto;background:#F5EFE6;border-radius:18px;border:1px solid #E7DFD0;overflow:hidden;">

  <div style="padding:20px 32px;border-bottom:1px solid #E7DFD0;">
    <table style="width:100%;border-spacing:0;"><tr>
      <td><div style="font-size:15px;font-weight:700;color:#1C1917;">SIGESPU</div>
          <div style="font-size:10px;color:#78716C;letter-spacing:0.18em;text-transform:uppercase;margin-top:2px;">Ilustre Municipalidad de Lota</div></td>
      <td style="text-align:right;"><span style="font-family:'Courier New',monospace;font-size:10px;color:#9A3412;background:#FFF7ED;padding:5px 10px;border-radius:6px;font-weight:600;border:1px solid #FED7AA;">$ref</span></td>
    </tr></table>
  </div>

  <div style="padding:40px 44px 28px;">
    <div style="font-size:10px;font-weight:700;letter-spacing:0.3em;text-transform:uppercase;color:#9A3412;margin-bottom:18px;">N° 002 · Recuperación de contraseña</div>
    <h1 style="font-size:44px;line-height:1;font-weight:700;letter-spacing:-0.03em;color:#1C1917;margin:0 0 18px 0;">
      Hola,<br><span style="color:#EA580C;font-style:italic;font-weight:500;">$nombre</span>.
    </h1>
    <p style="font-size:15px;line-height:1.65;color:#44403C;margin:0;">
      Recibimos una solicitud para restablecer tu contraseña de <strong style="color:#1C1917;">SIGESPU · Lota</strong>.
      Ingresa el código a continuación en la aplicación para definir una nueva contraseña.
    </p>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FFFEFB;border:1px solid #E7DFD0;border-radius:16px;padding:28px;">
      <div style="font-size:14px;font-weight:700;color:#1C1917;margin-bottom:4px;">Código de recuperación</div>
      <div style="font-size:12px;color:#78716C;margin-bottom:18px;">Válido por <strong style="color:#9A3412;">15 minutos</strong>. No lo compartas con nadie.</div>
      <table style="border-spacing:0;border-collapse:separate;"><tr>$codeBoxes</tr></table>
      <div style="margin-top:14px;font-size:12px;color:#78716C;">
        Vence el <strong style="color:#1C1917;">$expiraStr</strong>
      </div>
    </div>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FEF2F2;border:1px solid #FECACA;border-radius:12px;padding:14px 18px;font-size:12px;color:#7F1D1D;line-height:1.55;">
      <strong>¿No solicitaste cambiar tu contraseña?</strong> Ignora este correo y tu contraseña actual seguirá vigente. El código expirará automáticamente en 15 minutos.
    </div>
  </div>

  <div style="padding:22px 44px 26px;border-top:1px solid #E7DFD0;background:#EFE7DA;">
    <div style="font-size:11px;color:#78716C;line-height:1.7;">
      <strong style="font-size:12px;color:#1C1917;">Ilustre Municipalidad de Lota</strong><br>
      Dirección de Seguridad Pública · Aníbal Pinto 442, Lota · SIGESPU v1.0.0
    </div>
  </div>

</div>
</body>
</html>
''';
  }
}
