import 'package:nakos/features/auth/presentation/screens/login_screen.dart';
import 'package:nakos/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakos/main.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('KostSaverApp 4-tab navigation and top-right Catat Kilat test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KostSaverApp(home: DashboardHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsOneWidget);
    expect(find.text('Anak Kost'), findsOneWidget);
    expect(find.text('Saldo Terkini'), findsOneWidget);
    expect(find.text('Belum ada transaksi pengeluaran.'), findsOneWidget);

    final alokasiTab = find.byIcon(Icons.receipt_long_outlined);
    expect(alokasiTab, findsOneWidget);
    await tester.tap(alokasiTab);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsNothing);
    expect(find.text('Alokasi Anggaran'), findsOneWidget);
    expect(find.text('SURVIVAL BUDGET (UANG DINGIN)'), findsOneWidget);
    expect(find.text('Kebutuhan Wajib (Harga Mati)'), findsOneWidget);
    expect(find.text('Belum ada pos kebutuhan wajib.\nTekan "+ Tambah" di atas untuk memasukkan pengeluaran rutin.'), findsOneWidget);

    final dompetTab = find.byIcon(Icons.credit_card_outlined);
    expect(dompetTab, findsOneWidget);
    await tester.tap(dompetTab);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsNothing);
    expect(find.text('Dompet & Analisis'), findsOneWidget);
    expect(find.text('Kalender Hemat Bulanan'), findsOneWidget);

    final profilTab = find.byIcon(Icons.person_outline_rounded);
    expect(profilTab, findsOneWidget);
    await tester.tap(profilTab);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsNothing);
    expect(find.text('Profil & Cadangan'), findsOneWidget);
    expect(find.text('Cadangan Data'), findsOneWidget);

    final homeTab = find.byIcon(Icons.home_outlined);
    expect(homeTab, findsOneWidget);
    await tester.tap(homeTab);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsOneWidget);

    final catatButton = find.byIcon(Icons.add_rounded);
    expect(catatButton, findsOneWidget);
    await tester.tap(catatButton);
    await tester.pumpAndSettle();

    expect(find.text('Catat Pengeluaran'), findsOneWidget);
    expect(find.text('Simpan Transaksi (<3s)'), findsOneWidget);

    final closeButton = find.byIcon(Icons.close_rounded);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang,'), findsOneWidget);
    expect(find.text('Anak Kost'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('BudgetAllocationScreen income dropdown (Gaji/Kiriman) and savings dialog test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KostSaverApp(home: DashboardHomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Tabungan'), findsOneWidget);

    await tester.tap(find.text('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('Atur Pemasukan'), findsOneWidget);
    expect(find.text('Pemasukan Bulanan'), findsOneWidget);
    expect(find.text('Sumber Pemasukan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dropdown_sumber_pemasukan')));
    await tester.pumpAndSettle();

    expect(find.text('Gaji (Pekerja)'), findsWidgets);
    await tester.tap(find.text('Gaji (Pekerja)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Gaji'), findsOneWidget);

    await tester.tap(find.text('Tabungan'));
    await tester.pumpAndSettle();

    expect(find.text('Target Tabungan'), findsOneWidget);
    expect(find.text('Target Tabungan Dingin Bulanan'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
  });

  testWidgets('LoginScreen displays 3D cards and start now onboarding button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KostSaverApp(home: LoginScreen(enableAnimation: false)));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang'), findsWidgets);
    expect(find.text('Atur Keuanganmu, Hidup Lebih Mudah'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
