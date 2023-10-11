import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:formz_submit_button/formz_submit_button.dart';

class MockOnPressedFunction {
  int called = 0;

  void handler() {
    called++;
  }
}

void main() {
  late MockOnPressedFunction mockOnPressedFunction;

  setUp(() {
    mockOnPressedFunction = MockOnPressedFunction();
  });

  testWidgets(
    'should call tap function',
    (final tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: FormzSubmitButton(
                color: Colors.blue,
                onPressed: mockOnPressedFunction.handler,
                animateOnTap: false,
                width: 200,
                child: const Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FormzSubmitButton));
      expect(mockOnPressedFunction.called, 1);
    },
  );

  testWidgets(
    'should show progress indicator when in loading state',
    (final tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: FormzSubmitButton(
                color: Colors.blue,
                onPressed: mockOnPressedFunction.handler,
                width: 200,
                status: FormzSubmissionStatus.inProgress,
                child: const Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'should not show progress indicator when in idle state',
    (final tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: FormzSubmitButton(
                color: Colors.blue,
                onPressed: mockOnPressedFunction.handler,
                status: FormzSubmissionStatus.initial,
                width: 200,
                child: const Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'should show icon when in success state',
    (final tester) async {
      final key = GlobalKey<FormzSubmitButtonState>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: FormzSubmitButton(
                key: key,
                color: Colors.blue,
                onPressed: mockOnPressedFunction.handler,
                status: FormzSubmissionStatus.success,
                width: 200,
                successIcon: Icons.check,
                child: const Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
      key.currentState!.success();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'should show icon when in error state',
    (final tester) async {
      final key = GlobalKey<FormzSubmitButtonState>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: FormzSubmitButton(
                key: key,
                color: Colors.blue,
                onPressed: mockOnPressedFunction.handler,
                status: FormzSubmissionStatus.failure,
                width: 200,
                child: const Text(
                  'Tap me!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
      key.currentState!.success();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    },
  );
}
