/// Helper function to get currency symbol for a given currency code
String getCurrencySymbol(String currencyCode) {
  switch (currencyCode) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'PKR':
    default:
      return 'Rs.';
  }
}
