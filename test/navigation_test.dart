import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reverie_cineplex/main.dart';
import 'package:reverie_cineplex/widgets/movie_card.dart';
import 'package:reverie_cineplex/screens/booking/booking_flow.dart';
import 'package:reverie_cineplex/screens/movie/movie_detail.dart';

void main() {
  testWidgets('Home opens movie then booking; tabs reach profile and admin', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(
      find.text('ข้อมูลตัวอย่าง • ยังไม่ได้ตั้งค่า TMDB API'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailScreen), findsOneWidget);
    await tester.tap(find.text('เลือกรอบฉาย / จองตั๋ว'));
    await tester.pumpAndSettle();
    expect(find.byType(BookingFlow), findsOneWidget);
    expect(tester.widget<BookingFlow>(find.byType(BookingFlow)).movie!.id, -1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('ตั๋วของฉัน'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ยังไม่มีตั๋ว'), findsOneWidget);
    await tester.tap(find.text('โปรไฟล์'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('แอดมิน (ตัวอย่าง)'));
    await tester.pumpAndSettle();
    expect(find.text('จัดการโรงภาพยนตร์'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
