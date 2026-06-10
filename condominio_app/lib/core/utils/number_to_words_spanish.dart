class NumberToWordsSpanish {
  static const List<String> _unidades = [
    '', 'UN', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE'
  ];

  static const List<String> _decenas = [
    '', 'DIEZ', 'VEINTE', 'TREINTA', 'CUARENTA', 'CINCUENTA', 'SESENTA', 'SETENTA', 'OCHENTA', 'NOVENTA'
  ];

  static const List<String> _especiales = [
    'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE', 'DIECISEIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE'
  ];

  static const List<String> _veintes = [
    'VEINTIUNO', 'VEINTIDOS', 'VEINTITRES', 'VEINTICUATRO', 'VEINTICINCO', 'VEINTISEIS', 'VEINTISIETE', 'VEINTIOCHO', 'VEINTINUEVE'
  ];

  static const List<String> _centenas = [
    '', 'CIENTO', 'DOSCIENTOS', 'TRESCIENTOS', 'CUATROCIENTOS', 'QUINIENTOS', 'SEISCIENTOS', 'SETECIENTOS', 'OCHOCIENTOS', 'NOVECIENTOS'
  ];

  static String convert(double amount) {
    int integerPart = amount.truncate();
    int decimalPart = ((amount - integerPart).abs() * 100).round();

    String result = _convertGroup(integerPart);
    
    // Ajustes gramaticales para el formato de moneda
    if (result == 'UN') result = 'UN'; // Para "UN PESO"
    if (result == '') result = 'CERO';
    
    // Corrección para 100 exacto
    if (integerPart == 100) result = 'CIEN';

    String centsStr = decimalPart.toString().padLeft(2, '0');
    
    return "($result PESOS $centsStr/100 M.N.)";
  }

  static String _convertGroup(int n) {
    if (n == 0) return '';
    if (n < 10) return _unidades[n];
    if (n == 10) return 'DIEZ';
    if (n < 20) return _especiales[n - 11];
    if (n == 20) return 'VEINTE';
    if (n < 30) return _veintes[n - 21];
    if (n < 100) {
      int d = n ~/ 10;
      int u = n % 10;
      if (u == 0) return _decenas[d];
      return '${_decenas[d]} Y ${_unidades[u]}';
    }
    if (n < 1000) {
      int c = n ~/ 100;
      int rest = n % 100;
      if (c == 1 && rest == 0) return 'CIEN';
      if (rest == 0) return _centenas[c];
      return '${_centenas[c]} ${_convertGroup(rest)}';
    }
    if (n < 1000000) {
      int thousands = n ~/ 1000;
      int rest = n % 1000;
      String thousandsStr = thousands == 1 ? 'MIL' : '${_convertGroup(thousands)} MIL';
      if (rest == 0) return thousandsStr;
      return '$thousandsStr ${_convertGroup(rest)}';
    }
    
    return n.toString(); // Fallback for very large numbers if needed
  }
}
