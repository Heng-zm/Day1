import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For MaterialApp
import 'package:http/http.dart' as http;

class TelegramClient extends StatefulWidget {
  @override
  _TelegramClientState createState() => _TelegramClientState();
}

class _TelegramClientState extends State<TelegramClient>
    with TickerProviderStateMixin {
  TextEditingController _botTokenController = TextEditingController();
  TextEditingController _chatIdController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  List<String> sentMessages = []; // To store sent messages
  bool _isSending = false; // To track the button press animation
  late AnimationController _fadeController; // Controller for the fade animation
  late Animation<double>
      _fadeAnimation; // Fade animation for the message confirmation

  // Function to send message using the provided bot token
  Future<void> sendMessage(String botToken, String chatId, String text) async {
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

    final response = await http.post(
      url,
      body: {
        'chat_id': chatId,
        'text': text,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        sentMessages.add('Sent to $chatId: $text'); // Store sent messages
        _fadeController.forward(); // Start fade animation
      });
      print('Message sent successfully!');
      // Show the success pop-up dialog after message is sent
      _showSuccessDialog();
    } else {
      print('Failed to send message');
    }
  }

  // This will keep the form in a loop-like behavior for new input
  void sendMessageAndKeepInput() {
    String botToken = _botTokenController.text;
    String chatId = _chatIdController.text;
    String message = _messageController.text;

    if (botToken.isNotEmpty && chatId.isNotEmpty && message.isNotEmpty) {
      setState(() {
        _isSending = true; // Button pressed animation
      });
      sendMessage(botToken, chatId, message);

      // Do not clear Chat ID and Message fields, keep them ready for new input
    } else {
      print('Please enter Bot Token, Chat ID, and Message');
    }
  }

  // Function to show the success pop-up dialog
  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Icon(CupertinoIcons.check_mark_circled,
              color: CupertinoColors.activeGreen, size: 50),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Message Sent!',
                style:
                    TextStyle(fontSize: 18, color: CupertinoColors.activeBlue),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Telegram Client'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Input field for Bot Token using CupertinoTextField
              CupertinoTextField(
                controller: _botTokenController,
                placeholder: 'Enter Bot Token',
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.inactiveGray),
                ),
              ),
              SizedBox(height: 10),
              // Input field for Chat ID (numeric values accepted) using CupertinoTextField
              CupertinoTextField(
                controller: _chatIdController,
                keyboardType: TextInputType.number,
                placeholder: 'Enter Numeric Chat ID',
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.inactiveGray),
                ),
              ),
              SizedBox(height: 10),
              // Input field for message text using CupertinoTextField
              CupertinoTextField(
                controller: _messageController,
                placeholder: 'Enter Message',
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.inactiveGray),
                ),
              ),
              SizedBox(height: 20),
              // CupertinoButton to send the message with animation on press
              CupertinoButton.filled(
                onPressed: () {
                  sendMessageAndKeepInput(); // Do not clear Chat ID and Message fields
                },
                child: _isSending
                    ? CupertinoActivityIndicator() // Show activity indicator when sending
                    : Text('Send Message'),
              ),
              SizedBox(height: 20),
              Text('Messages Sent:'),
              // Display sent messages
              Expanded(
                child: ListView.builder(
                  itemCount: sentMessages.length,
                  itemBuilder: (context, index) {
                    return CupertinoListTile(
                      title: Text(sentMessages[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(CupertinoApp(
    home: TelegramClient(),
  ));
}
