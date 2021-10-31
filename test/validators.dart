class ValidateEntries {
  //validation for user inputs to formfields

  String validateUsername(String val) {
    if (val.trim().length < 3 || val.trim().length == 0) {
      return "Enter valid Name";
    } else {
      return 'null';
    }
  }

  String validateUserAge(String val) {
    if (val.trim().length > 2 ||
        val.trim().length == 0 ||
        (int.parse(val) < 18)) {
      return "Enter valid Age";
    } else {
      return 'null';
    }
  }

  String validateUserContact(String val) {
    if (val.trim().length != 10 ||
        val.contains(RegExp(r'[^0-9]')) ||
        !val.startsWith('0')) {
      return "Enter valid Contact Number";
    } else {
      return 'null';
    }
  }

  String validateCityName(String val) {
    if (val.trim().length < 3 ||
        val.trim().length == 0 ||
        val.trim().length > 20) {
      return "Enter a valid City Name";
    } else {
      return 'null';
    }
  }
}
