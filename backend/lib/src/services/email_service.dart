import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  final String _user;
  final String _pass;

  EmailService()
      : _user = Platform.environment['SMTP_USER'] ?? '',
        _pass = Platform.environment['SMTP_PASS'] ?? '';

  Future<void> sendVerificationCode(
      String toEmail, String nombre, String codigo) async {
    final smtpServer = gmail(_user, _pass);
    final message = Message()
      ..from = Address(_user, 'SIGESPU Lota')
      ..recipients.add(toEmail)
      ..subject = 'Activa tu cuenta SIGESPU · Código de verificación'
      ..html = buildHtml(nombre, codigo);

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('[EmailService] Error al enviar correo a $toEmail: $e');
    }
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
}
