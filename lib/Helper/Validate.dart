class Validate {
  static String? username(String? text) {
    if (text == null) {
      return "Bitte gib einen richtigen Namen ein!";
    }

    if (text.length < 3) {
      return "Bitte gib einen richtigen Namen ein!";
    }
    if (text.length > 15) return "Dieser Name ist zu lang!";
    return null;
  }

  static String? email(String? text) {
    if (text == null) return "Gib eine Emailadresse an!";
    if (!RegExp(
            "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$")
        .hasMatch(text)) {
      return "Bitte gib eine richtige Emailadresse ein!";
    }
    return null;
  }

  static String? telephone(String? text) {
    if (text == null) return null;
    if (text.isEmpty) return null;
    if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
        .hasMatch(text)) {
      return 'Bitte gib eine richtige Telefonnummer ein.';
    }
    return null;
  }

  static String? password(String? text) {
    if (text == null)
      return "Das Passwort muss aus mindestens 8 Zeichen bestehen!";
    if (text.length < 7)
      return "Das Passwort muss aus mindestens 8 Zeichen bestehen!";
    if (text.length >= 32)
      return "Das Passwort darf maximal aus 32 Zeichen besthen!";
    return null;
  }

  static String? postTitle(String text) {
    if (text.length < 3) return "Der Titel ist zu kurz!";
    return null;
  }

  static String? postText(String text) {
    if (text.length < 20) return "Beschreibung zu kurz!";
    return null;
  }
}
