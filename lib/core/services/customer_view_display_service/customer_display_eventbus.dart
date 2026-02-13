// import 'dart:async';

// /// Global Event Bus for Customer Display Data
// /// This allows any widget to listen to customer display updates
// class CustomerDisplayEventBus {
//   // Singleton pattern
//   static final CustomerDisplayEventBus _instance =
//       CustomerDisplayEventBus._internal();
//   factory CustomerDisplayEventBus() => _instance;
//   CustomerDisplayEventBus._internal();

//   // Stream controller for broadcasting events
//   final _controller = StreamController<Map<String, dynamic>>.broadcast();

//   /// Stream that widgets can listen to
//   Stream<Map<String, dynamic>> get stream => _controller.stream;

//   /// Publish new data to all listeners
//   void publish(Map<String, dynamic> data) {
//     if (!_controller.isClosed) {
//       _controller.add(data);
//       print(' CustomerDisplayEventBus: Data published to all listeners');
//     }
//   }

//   /// Clean up resources
//   void dispose() {
//     _controller.close();
//   }
// }
