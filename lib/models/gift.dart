class Gift {
  final int amount;
  final String message;

  const Gift({required this.amount, this.message = "Du hast ** DV bekommen!"});

  factory Gift.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return Gift.zero();

    return Gift(
      amount: map['amount']!,
      message: map['message'] ?? "Du hast ** DV bekommen!",
    );
  }

  const Gift.zero()
      : amount = 0,
        message = "Du hast ** DV bekommen!";

  @override
  String toString() => 'Gift(amount: $amount, message: $message)';
}
