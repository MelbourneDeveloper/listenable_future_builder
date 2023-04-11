import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

void main() {
  testWidgets('ListenableFutureBuilder updates UI when future resolves',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<int>>(
          listenable: () async => ValueNotifier<int>(42),
          builder: (
            context,
            child,
            snapshot,
          ) =>
              snapshot.connectionState == ConnectionState.done
                  ? Text('${snapshot.data!.value}')
                  : const CircularProgressIndicator(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('42'), findsNothing);

    // Wait for future to resolve
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that Text widget with value 42 is shown after future resolves
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('ListenableFutureBuilder updates UI when future errors',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<int>>(
          listenable: () async => Future<ValueNotifier<int>>.delayed(
            const Duration(milliseconds: 500),
            () => throw Exception('Oops'),
          ),
          builder: (
            context,
            child,
            snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.error != null) {
              final dynamic error = snapshot.error as dynamic;
              // ignore: avoid_dynamic_calls
              final errorMessage = 'Error: ${error.message}';
              return Text(errorMessage);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );

    // Verify that CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Error: Oops'), findsNothing);

    // Wait for future to resolve
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that Text widget with error message is shown after future errors
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Error: Oops'), findsOneWidget);
  });

  testWidgets('ListenableFutureBuilder updates UI when future returns null',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<String?>>(
          listenable: () async => ValueNotifier<String?>(null),
          builder: (
            context,
            child,
            snapshot,
          ) =>
              snapshot.connectionState == ConnectionState.done
                  ? Text(
                      snapshot.data?.value == null
                          ? 'Nothing'
                          : snapshot.data!.value!,
                    )
                  : const CircularProgressIndicator(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Nothing'), findsNothing);

    // Wait for future to resolve
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that Text widget with value null is shown after future resolves
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nothing'), findsOneWidget);
  });

  testWidgets(
      'ListenableFutureBuilder updates UI when future takes a while to resolve',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<int>>(
          listenable: () async => Future<ValueNotifier<int>>.delayed(
            const Duration(seconds: 2),
            () => ValueNotifier<int>(42),
          ),
          builder: (
            context,
            child,
            snapshot,
          ) =>
              snapshot.connectionState == ConnectionState.done
                  ? Text('${snapshot.data!.value}')
                  : const CircularProgressIndicator(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('42'), findsNothing);

    // Wait for future to resolve
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that Text widget with value 42 is shown after future resolves
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('ListenableFutureBuilder updates UI when the notifier is changed',
      (tester) async {
    final notifier = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<int>>(
          listenable: () async => notifier,
          builder: (
            context,
            child,
            snapshot,
          ) =>
              snapshot.connectionState == ConnectionState.done
                  ? Text('${snapshot.data!.value}')
                  : const CircularProgressIndicator(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('0'), findsNothing);

    // Wait for future to resolve
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify that Text widget with value 0 is shown after future resolves
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('0'), findsOneWidget);

    // Increment the value of the notifier
    notifier.value = 1;

    // Verify that Text widget with value 1 is shown after notifier is changed
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  ///Notes: we need to confirm that the builder drops its reference to the
  ///Listenable when the widget is disposed. If the state holds onto a
  ///previous AsyncSnapshot, it will hold onto the Listenable as well. This
  ///test ensures that the State doesn't hold onto the Listenable after
  ///disposal.
  testWidgets('ListenableFutureBuilder disposes correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableFutureBuilder<ValueNotifier<int?>>(
          listenable: () async => ValueNotifier<int?>(3),
          builder: (
            context,
            child,
            snapshot,
          ) =>
              snapshot.connectionState == ConnectionState.done
                  ? Text('${snapshot.data!.value}')
                  : const CircularProgressIndicator(),
        ),
      ),
    );

    //_ListenableFutureBuilderState is private so we cannot access the state
    //without dynamic
    final dynamic state =
        tester.state(find.byType(ListenableFutureBuilder<ValueNotifier<int?>>));

    //Triggers disposal
    await tester.pumpWidget(const SizedBox());

    final snapshot =
        //We have lastSnapshot so we can test this. Alternative approaches to
        //testing for this are absolutely welcome, and we can remove this
        //getter if it is too problematic.
        // ignore: avoid_dynamic_calls
        state.lastSnapshot as AsyncSnapshot<ValueNotifier<int?>>;

    //Verify the state does not hold onto the Listenable after disposal
    expect(snapshot.data, isNull);
    expect(snapshot.connectionState, ConnectionState.none);
  });

  testWidgets('Dispose calls disposeListenable when the widget is disposed',
      (tester) async {
    // Create a ValueNotifier to be used in the test
    final valueNotifier = ValueNotifier<int>(0);
    var disposeListenableCalled = false;

    // Define the disposeListenable function
    Future<ValueNotifier<int>> disposeListenable(
      ValueNotifier<int> listenable,
    ) {
      disposeListenableCalled = true;
      return Future<ValueNotifier<int>>.value(listenable);
    }

    // Define a simple widget tree with the ListenableFutureBuilder
    final app = MaterialApp(
      home: ListenableFutureBuilder<ValueNotifier<int>>(
        listenable: () async => valueNotifier,
        builder: (
          context,
          child,
          listenableSnapshot,
        ) =>
            const Text('Test'),
        disposeListenable: disposeListenable,
      ),
    );

    // Pump the widget
    await tester.pumpWidget(app);

    // Wait for the async operation to complete
    await tester.pumpAndSettle();

    // Trigger a rebuild and dispose of the widget
    await tester.pumpWidget(const SizedBox());

    // Check if disposeListenable was called
    expect(disposeListenableCalled, true);
  });
}
