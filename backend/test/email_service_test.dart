import 'package:test/test.dart';
import '../lib/src/services/email_service.dart';

void main() {
  group('EmailService.buildHtml', () {
    test('contains nombre in output', () {
      final html = EmailService.buildHtml('Juan Pérez', '483920');
      expect(html, contains('Juan Pérez'));
    });

    test('renders each digit as a separate cell', () {
      final html = EmailService.buildHtml('Ana', '123456');
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        expect(html, contains('>$d<'));
      }
    });

    test('contains 15 minutos expiry text', () {
      final html = EmailService.buildHtml('Luis', '000000');
      expect(html, contains('15 minutos'));
    });

    test('contains REF– reference', () {
      final html = EmailService.buildHtml('María', '111111');
      expect(html, contains('REF–'));
    });
  });
}
