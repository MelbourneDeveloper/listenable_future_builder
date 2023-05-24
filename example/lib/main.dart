import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';
import 'package:listenable_future_builder/listenable_propagator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: ListenableFutureBuilder<ValueNotifier<int>>(
          //We get an instance of the controller here and
          //ListenableFutureBuilder will hold onto it and rebuild the widget
          //tree on notifications
          listenable: getController,
          builder: (context, child, snapshot) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: switch (snapshot) {
                AsyncSnapshot(hasData: true) => ListenablePropagator(
                    listenable: snapshot.data!,
                    child: const CounterDisplay(),
                  ),
                AsyncSnapshot(hasError: true) => const Text('Error'),
                AsyncSnapshot() => const CircularProgressIndicator.adaptive()
              },
            ),
            floatingActionButton: FloatingActionButton(
              //We increment the counter if the controller is ready
              onPressed: () => snapshot.data?.value++,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
}

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '${ListenablePropagator.of<ValueNotifier<int>>(context).value}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      );
}

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
