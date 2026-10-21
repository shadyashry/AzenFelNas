/// The bytes of lowercase [hex], or `null` when it is not an even number of
/// lowercase hex digits.
List<int>? hexBytes(String hex) {
  if (hex.length.isOdd || !_lowerHex.hasMatch(hex)) return null;
  return [
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ];
}

final RegExp _lowerHex = RegExp(r'^[0-9a-f]*$');
