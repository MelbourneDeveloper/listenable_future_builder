import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

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

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
