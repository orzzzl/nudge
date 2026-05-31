import 'package:flutter/material.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).chatPlaceholderLabel),
      ),
    );
  }
}
