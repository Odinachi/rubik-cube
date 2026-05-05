import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rubik_app/core/app_strings.dart';
import 'package:rubik_app/cube/cube_controls.dart';
import 'package:rubik_app/cube/cube_view.dart';
import 'package:confetti/confetti.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: CubeView(),
    );
  }

  group('CubeView Initial Rendering & Layout Tests', () {
    testWidgets('renders App Bar, actions, and CubeControls', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Settle any initial animations

      // Verify AppBar texts
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.byTooltip(AppStrings.hintTooltip), findsOneWidget);
      expect(find.byTooltip(AppStrings.autoSolveTooltip), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Verify CubeControls exists
      expect(find.byType(CubeControls), findsOneWidget);
    });

    testWidgets('layout adjusts based on screen width (Wide)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // In wide mode, it uses a Row for the main content
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsWidgets);
      
      // Look for the Expanded that contains the gesture detector
      final expandedFinder = find.byType(Expanded);
      expect(expandedFinder, findsWidgets);
    });

    testWidgets('layout adjusts based on screen width (Narrow)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // In narrow mode, it uses a Column for main content
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsWidgets);
    });
  });

  group('CubeView App Bar Action Tests', () {
    testWidgets('Hint on already solved cube', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.hintTooltip));
      await tester.pump(); // Pump frame for snackbar

      expect(find.text(AppStrings.alreadySolvedMsg), findsOneWidget);
    });

    testWidgets('Auto Solve on already solved cube', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(AppStrings.autoSolveTooltip));
      await tester.pump(); // Pump frame for snackbar

      expect(find.text(AppStrings.alreadySolvedMsg), findsOneWidget);
    });

    testWidgets('Reset clears rotations', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Emulate drag to rotate
      await tester.drag(find.byType(GestureDetector).first, const Offset(100, 100));
      await tester.pump();

      // Tap reset
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify it doesn't crash and renders correctly
      expect(find.byType(CubeView), findsOneWidget);
    });
  });

  group('CubeView Manual Moves & History Tracking Tests', () {
    testWidgets('makes a move and hint suggests reverse', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'U'
      await tester.tap(find.text(AppStrings.moveU));
      await tester.pumpAndSettle();

      // Tap hint
      await tester.tap(find.byTooltip(AppStrings.hintTooltip));
      await tester.pump(); // SnackBar appears

      // The reverse of U could be U'
      expect(find.textContaining('Hint: Play'), findsOneWidget);
      expect(find.text(AppStrings.alreadySolvedMsg), findsNothing);
    });
  });

  group('CubeView Auto Solve Mechanism Tests', () {
    testWidgets('makes moves and auto solves', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'R'
      await tester.tap(find.text(AppStrings.moveR));
      await tester.pumpAndSettle();

      // Tap Auto Solve
      await tester.tap(find.byTooltip(AppStrings.autoSolveTooltip));
      
      // Auto solve pops moves and waits 150ms per move
      // Then confetti plays for 3s. So we just advance time explicitly.
      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Hint should now say it's solved
      await tester.tap(find.byTooltip(AppStrings.hintTooltip));
      await tester.pump();

      expect(find.text(AppStrings.alreadySolvedMsg), findsOneWidget);
      // Confetti widget might be playing, verify it exists
      expect(find.byType(ConfettiWidget), findsOneWidget);
    });

    testWidgets('blocks interactions while auto solving', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Make 3 moves
      await tester.tap(find.text(AppStrings.moveR));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.moveU));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.moveL));
      await tester.pumpAndSettle();

      // Tap Auto Solve
      await tester.tap(find.byTooltip(AppStrings.autoSolveTooltip));
      await tester.pump(); // Start solving

      // Try to tap 'D' while it is solving
      await tester.tap(find.text(AppStrings.moveD));
      await tester.pump();

      // Finish solving explicitly
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }

      // If 'D' was ignored, the cube should be solved.
      await tester.tap(find.byTooltip(AppStrings.hintTooltip));
      await tester.pump();
      
      expect(find.text(AppStrings.alreadySolvedMsg), findsOneWidget);
    });
  });

  group('CubeView Scramble Mechanism Tests', () {
    testWidgets('scrambles and blocks interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap scramble
      await tester.tap(find.text(AppStrings.scrambleButton));
      
      // Start of scramble
      await tester.pump();
      
      // While scrambling, try to tap 'U'
      await tester.tap(find.text(AppStrings.moveU));
      await tester.pump();

      // Finish scrambling (20 moves * 150ms)
      for (int i = 0; i < 21; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      await tester.pumpAndSettle();

      // Verify we have moves by checking if hint suggests something other than solved
      await tester.tap(find.byTooltip(AppStrings.hintTooltip));
      await tester.pump();

      expect(find.text(AppStrings.alreadySolvedMsg), findsNothing);
      expect(find.textContaining('Hint: Play '), findsOneWidget);
    });
  });

  group('CubeView Gesture Interaction Tests', () {
    testWidgets('Pan update modifies rotation', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the cube area gesture detector
      final gestureFinder = find.byType(GestureDetector).first;
      
      await tester.drag(gestureFinder, const Offset(50.0, -50.0));
      await tester.pump();

      expect(find.byType(CubeView), findsOneWidget);
    });
  });
}
