import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';
import 'package:listenable_future_builder/listenable_propagator.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: ListenableFutureBuilder<ValueNotifier<int>>(
        listenable: getController,
        builder: (context, child, snapshot) => Scaffold(
          appBar: AppBar(),
          body: Center(
              child: snapshot.hasData
                  ? ListenablePropagator(
                      listenable: snapshot.data!,
                      child: const CounterDisplay(),
                    )
                  : snapshot.hasError
                      ? const Text('Error')
                      : const CircularProgressIndicator.adaptive()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => snapshot.data?.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
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
