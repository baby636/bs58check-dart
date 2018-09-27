import 'package:crypto/crypto.dart' show sha256, Digest;
import 'dart:typed_data';
import 'utils/base.dart';
import 'dart:convert';
final String ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
final base58 = new Base(ALPHABET);

Uint8List _sha256x2(Uint8List buffer) {
  // SHA256(SHA256(buffer))
  Digest tmp = sha256.newInstance().convert(buffer);
  return sha256.newInstance().convert(tmp.bytes).bytes;
}
String encode(Uint8List payload) {
  Uint8List hash = _sha256x2(payload);
  Uint8List combine = Uint8List.fromList([payload, hash.sublist(0, 4)].expand((i) => i).toList(growable: false));
  return base58.encode(combine);
}
Uint8List decodeRaw(Uint8List buffer) {
  Uint8List payload = buffer.sublist(0, buffer.length - 4);
  Uint8List checksum = buffer.sublist(buffer.length - 4);
  Uint8List newChecksum = _sha256x2(payload);
  if (
    checksum[0] != newChecksum[0] ||
    checksum[1] !=  newChecksum[1] ||
    checksum[2] !=  newChecksum[2] ||
    checksum[3] !=  newChecksum[3]
  ) {
    throw new ArgumentError("Invalid checksum");
  }
  return payload;
}
Uint8List decode(String string) {
  Uint8List buffer = base58.decode(string);
  return decodeRaw(buffer);
}