// Smoke test: home + bottom nav (4 tab: Beranda, Cari, Favorit, Pengaturan).

import 'package:flutter_test/flutter_test.dart';
import 'package:resep_makanan/main.dart';

void main() {
  testWidgets('app renders home with bottom navigation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Mau masak apa'), findsNothing); // headlineMedium multiline
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}
