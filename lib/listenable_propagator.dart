library listenable_future_builder;

import 'package:flutter/material.dart';

///Propagates a [Listenable] to its descendants. Works well with [ListenableFutureBuilder]
///when there is a complicated widget tree in the ListenableFutureBuilder's builder.
class ListenablePropagator<T extends Listenable> extends InheritedWidget {
  ///Creates a ListenablePropagator
  const ListenablePropagator({
    required this.listenable,
    required super.child,
    super.key,
  });

  final T listenable;

  static T of<T extends Listenable>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ListenablePropagator<T>>();
    if (provider == null) {
      throw FlutterError('No ListenableProvider<$T> found in the widget tree.');
    }
    return provider.listenable;
  }

  @override
  bool updateShouldNotify(ListenablePropagator<T> oldWidget) =>
      oldWidget != this;
}
