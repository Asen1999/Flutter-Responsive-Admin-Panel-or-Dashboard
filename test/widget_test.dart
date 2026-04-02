import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/features/history/presentation/providers/generation_history_provider.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('main menu can switch to image create and history pages',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          canvasColor: secondaryColor,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<MenuAppController>(
              create: (BuildContext context) => MenuAppController(),
            ),
            ChangeNotifierProvider<GenerationHistoryProvider>(
              create: (BuildContext context) => GenerationHistoryProvider(),
            ),
          ],
          child: MainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Image Create'), findsOneWidget);

    await tester.tap(find.text('Image Create'));
    await tester.pumpAndSettle();
    expect(find.text('Tile Style'), findsOneWidget);

    await tester.tap(find.text('History Image List'));
    await tester.pumpAndSettle();
    expect(find.text('Generated History'), findsOneWidget);
  });
}
