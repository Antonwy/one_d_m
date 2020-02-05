class Validate {
  static String username(String text) {
    if (text.length < 4 || text.length >= 32)
      return "Bitte gib einen richtigen Namen ein!";
    return null;
  }

  static String email(String text) {
    if (!RegExp(
            "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$")
        .hasMatch(text)) {
      return "Bitte gib eine richtige Emailadresse ein!";
    }
    return null;
  }

  static String password(String text) {
    if (text.length < 7 || text.length >= 32)
      return "Bitte gib ein richtiges Passwort ein!";
    return null;
  }
}
