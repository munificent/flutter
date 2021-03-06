// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// A [Future] whose [then] implementation calls the callback immediately.
///
/// This is similar to [new Future.value], except that the value is available in
/// the same event-loop iteration.
///
/// ⚠ This class is useful in cases where you want to expose a single API, where
/// you normally want to have everything execute synchronously, but where on
/// rare occasions you want the ability to switch to an asynchronous model. **In
/// general use of this class should be avoided as it is very difficult to debug
/// such bimodal behavior.**
class SynchronousFuture<T> implements Future<T> {
  /// Creates a synchronous future.
  ///
  /// See also [new Future.value].
  SynchronousFuture(this._value);

  final T _value;

  @override
  Stream<T> asStream() {
    final StreamController<T> controller = new StreamController<T>();
    controller.add(_value);
    controller.close();
    return controller.stream;
  }

  @override
  Future<T> catchError(Function onError, { bool test(dynamic error) }) => new Completer<T>().future;

  @override
  Future<dynamic/*=E*/> then/*<E>*/(dynamic f(T value), { Function onError }) {
    dynamic result = f(_value);
    if (result is Future<dynamic/*=E*/>)
      return result;
    return new SynchronousFuture<dynamic/*=E*/>(result);
  }

  @override
  Future<T> timeout(Duration timeLimit, { Future<T> onTimeout() }) => new Completer<T>().future;

  @override
  Future<T> whenComplete(Future<T> action()) => action();
}