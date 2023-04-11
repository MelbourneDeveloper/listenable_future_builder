import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      ListenableFutureBuilder<ValueNotifier<int>>(
        listenable: getController,
        builder: (context, child, snapshot) => Scaffold(
          appBar: AppBar(),
          body: Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'You have pushed the button this many times:',
                        ),
                        Text(
                          '${snapshot.data!.value}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    )
                  : const CircularProgressIndicator.adaptive()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => snapshot.data?.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
      );
}

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
