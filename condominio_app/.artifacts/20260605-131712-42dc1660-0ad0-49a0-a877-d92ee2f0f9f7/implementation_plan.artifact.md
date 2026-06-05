# Fix: PDF Font Crash and Reliable WhatsApp Attachment

The previous implementation failed because:
1.  **Corrupt Fonts**: The local `CustomFont.ttf` files are invalid (~300 bytes), causing a `RangeError`.
2.  **Background Intent Blocking**: Opening WhatsApp with `url_launcher` pushes the app to the background, preventing `Share.shareXFiles` from showing the share sheet on many devices.

## Proposed Changes

### Core Utilities

#### [receipt_pdf_utils.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/core/utils/receipt_pdf_utils.dart)
- **Safe Font Loading**: Use `PdfGoogleFonts` (from the `printing` package) with a try-catch fallback to standard Helvetica.
- **Guided Sharing Flow**:
    - First, open the WhatsApp chat with the text.
    - Second, show a clear Dialog in the app: "Chat abierto. ¿Deseas adjuntar el PDF ahora?".
    - Third, call `Share.shareXFiles` only after the user interacts with the dialog (ensuring the app is in the foreground).
- **Signature Cleanup**: Improve error handling when loading the admin signature.

### Presentation Layer

#### [income_screen.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/presentation/screens/admin/income_screen.dart)
- Pass the `BuildContext` to `generateAndShareReceipt`.

#### [finance_screen.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/presentation/screens/admin/finance_screen.dart)
- Pass the `BuildContext` to `generateAndShareReceipt`.

## Technical Details

### Guided Flow Logic
```dart
    // 1. Open WhatsApp
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);

    // 2. Show guidance dialog when user returns
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("¡Chat abierto!"),
        content: Text("Regresa aquí y presiona 'ADJUNTAR' para enviar el recibo PDF al chat."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Share.shareXFiles([XFile(file.path)], text: message);
            },
            child: Text("ADJUNTAR PDF"),
          ),
        ],
      ),
    );
```

## Verification Plan

### Manual Verification
1.  Register a manual payment.
2.  Click "SÍ, ENVIAR AHORA".
3.  Observe:
    -   No `RangeError` crash.
    -   WhatsApp opens with the correct text.
    -   Return to the app and see the "¡Chat abierto!" dialog.
    -   Click "ADJUNTAR PDF" and select WhatsApp in the share sheet.
    -   Verify the PDF is now correctly attached.
