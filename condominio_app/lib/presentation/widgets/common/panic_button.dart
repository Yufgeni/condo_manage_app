import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PanicButton extends StatelessWidget {
  const PanicButton({Key? key}) : super(key: key);

  Future<void> _makePanicCall(BuildContext context) async {
    final Uri url = Uri.parse('tel:911');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo realizar la llamada al 911')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.warning, color: Colors.red, size: 30),
        onPressed: () => _makePanicCall(context),
        tooltip: 'BOTÓN DE PÁNICO (911)',
      ),
    );
  }
}