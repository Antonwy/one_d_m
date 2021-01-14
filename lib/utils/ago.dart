String timeAgoSinceDate(DateTime dateString, {bool numericDates = true}) {
  final date2 = DateTime.now();
  final difference = date2.difference(dateString);

  if ((difference.inDays / 365).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} yrs ago';
  } else if ((difference.inDays / 365).floor() >= 1) {
    return (numericDates) ? '1 yrs ago' : 'Last year';
  } else if ((difference.inDays / 30).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} mon. ago';
  } else if ((difference.inDays / 30).floor() >= 1) {
    return (numericDates) ? '1 \nmon. ago' : 'Last month';
  } else if ((difference.inDays / 7).floor() >= 2) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if ((difference.inDays / 7).floor() >= 1) {
    return (numericDates) ? '1 \nwk. ago' : 'Last \nweek';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} \ndays ago';
  } else if (difference.inDays >= 1) {
    return (numericDates) ? '1 \nday ago' : 'Yesterday';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} \nhrs. ago';
  } else if (difference.inHours >= 1) {
    return (numericDates) ? '1 \nhrs. ago' : 'An hrs. ago';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} \nmin. ago';
  } else if (difference.inMinutes >= 1) {
    return (numericDates) ? '1 \nmin. ago' : 'A min. ago';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} \nsec. ago';
  } else {
    return 'Just now';
  }
}
String dateDifference(DateTime start,DateTime end ) {
  final difference = end.difference(start);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(difference.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(difference.inSeconds.remainder(60));
  return "${twoDigits(difference.inHours)}:$twoDigitMinutes:$twoDigitSeconds";

}