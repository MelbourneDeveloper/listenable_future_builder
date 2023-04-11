# listenable_future_builder

![badge](https://github.com/MelbourneDeveloper/listenable_future_builder/actions/workflows/build_and_test.yml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/listenable_future_builder"><img src="https://codecov.io/gh/melbournedeveloper/listenable_future_builder/branch/main/graph/badge.svg" alt="codecov"></a>

## Introduction

We often use [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) and [`ValueNotifier<>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) as controllers behind `StatelessWidget`s. However, there are two issues:

- A vanilla `StatelessWidget` cannot hold onto the controller because it could rebuild and lose the state at any time.
- We sometimes need to do async work before we can use the controller.

`ListenableFutureBuilder` solves these issues by acting like a hybrid of [`AnimatedBuilder`](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html) and [`FutureBuilder`](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html). 

Do this:

```dart
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
```

Instead of this:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<int>? _controller;

  @override
  void initState() {
    super.initState();
    _getController();
  }

  Future<void> _getController() async {
    final controller = await getController();
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _controller!.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          body: _controller != null
              ? AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) => Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'You have pushed the button this many times:',
                          ),
                          Text(
                            '${_controller!.value}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      )))
              : const CircularProgressIndicator.adaptive(),
        ),
        debugShowCheckedModeBanner: false,
      );
}

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
```

Notice that the second version is far more verbose than the version with `ListenableFutureBuilder`. This is because `ListenableFutureBuilder` creates your controller for you on the first call and hangs onto the controller for the lifespan of the widget. That means you don't need to create a `StatefulWidget` / `State` pair to hold onto the controller.