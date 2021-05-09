import 'dart:typed_data';

abstract class Answer<T> {
  int code;
  T process(Uint8List msg);
}