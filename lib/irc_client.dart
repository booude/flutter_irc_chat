import 'dart:io';

class IrcClient {
  late Socket _socket;
  late String _userName;
  late String _channelName;
  late Function(String) _onMessage;

  IrcClient({required Function(String) onMessage}) {
    _onMessage = onMessage;
    _userName = 'flutter_irc_chat';
    _channelName = '#unama';
  }

  void connect() {
    Socket.connect('irc.libera.chat', 6667).then((socket) {
      _socket = socket;

      _socket.writeln('NICK $_userName');
      _socket.writeln('USER $_userName 0 * :Daniel Calliari');

      _socket.listen((data) {
        var lines = String.fromCharCodes(data).split('\r\n');

        for (var line in lines) {
          if (line.startsWith('PING')) {
            _socket.writeln('PONG :${line.substring(5)}');
          } else if (line.contains(' 001 ')) {
            _socket.writeln('JOIN $_channelName');
          } else if (line.contains(' PRIVMSG ')) {
            var senderInfo = line.split('!')[0].substring(1);
            var nickname = senderInfo.split('@')[0];
            var message = line.split(' PRIVMSG ')[1].split(' :')[1];
            _onMessage('$nickname: $message');
          }
        }
      });
    }).catchError((error) {
      print('Error connecting to the IRC server: $error');
    });
  }

  void sendMessage(String message) {
    _socket.writeln('PRIVMSG $_channelName :$message');
  }

  void dispose() {
    _socket.close();
  }
}
