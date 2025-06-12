import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../models/chat_message.dart';
import '../../../models/current_user_response.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_socket_service.dart';
import '../../../services/user_service.dart';
import '../../../shared/main_app_bar.dart';
import '../../../models/chat_response.dart';
import '../widgets/message_bubbles.dart';
import '../widgets/chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  final ValueNotifier<String?> _floatingDate = ValueNotifier(null);

  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  final TextEditingController _controller = TextEditingController();
  int? _userId;
  ChatResponse? _chat;

  @override
  void initState() {
    super.initState();
    _init();
    _positions.itemPositions.addListener(_updateFloatingDate);
  }

  Future<void> _init() async {
    final chatsRes = await ChatService.instance.getChats();
    final chats = (chatsRes.data as List<dynamic>)
        .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    _chat = chats.firstWhere(
      (c) => c.id == widget.chatId,
      orElse: () => ChatResponse.fromJson({
        'id': widget.chatId,
        'type': 'PRIVATE',
        'title': 'Chat ${widget.chatId}',
        'eventId': null,
        'participantIds': [],
        'lastMessage': null,
        'unreadCount': 0,
      }),
    );
    ChatSocketService.instance.updateChatTitle(widget.chatId, _chat!.title);
    final userRes = await UserService.instance.getCurrentUser();
    _userId = CurrentUserResponse.fromJson(userRes.data).id;
    ChatSocketService.instance.setCurrentUserId(_userId!);
    await _loadMessages();
    if (mounted) setState(() {});
    ChatSocketService.instance.connect();
    ChatSocketService.instance.subscribe(widget.chatId);
    ChatSocketService.instance.setActiveChat(widget.chatId);
    ChatSocketService.instance.messagesForChat(widget.chatId).listen((msg) {
      setState(() => _messages.add(msg));
      _scrollController.scrollTo(
          index: _items.length - 1,
          duration: const Duration(milliseconds: 200));
    });
  }

  @override
  void dispose() {
    ChatSocketService.instance.setActiveChat(null);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ChatService.instance
          .getMessages(widget.chatId, page: _page, limit: 20);
      final list = (res.data as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.length < 20) _hasMore = false;
      _page++;
      _messages.insertAll(0, list.reversed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> get _items {
    final items = <dynamic>[];
    DateTime? lastDay;
    for (final m in _messages) {
      final ts = DateTime.parse(m.timestamp).toLocal();
      final day = DateTime(ts.year, ts.month, ts.day);
      if (lastDay == null || day.isAfter(lastDay)) {
        items.add(day);
        lastDay = day;
      }
      items.add(m);
    }
    return items;
  }

  void _updateFloatingDate() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions.where((p) => p.itemTrailingEdge > 0).reduce(
        (value, element) => value.index < element.index ? value : element);
    final item = _items[first.index];
    String date;
    if (item is DateTime) {
      date = DateFormat.yMMMd().format(item);
    } else if (item is ChatMessage) {
      final ts = DateTime.parse(item.timestamp).toLocal();
      date = DateFormat.yMMMd().format(ts);
    } else {
      date = '';
    }
    _floatingDate.value = date;
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    if (item is DateTime) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            DateFormat.yMMMd().format(item),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );
    }
    final msg = item as ChatMessage;
    final isMe = _userId != null && msg.senderId == _userId;
    return isMe
        ? SentMessageBubble(message: msg)
        : ReceivedMessageBubble(message: msg);
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_userId != null) {
      ChatSocketService.instance.sendMessage(widget.chatId, text);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _chat != null
          ? ChatAppBar(chat: _chat!)
          : const MainAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (n) {
                    if (_positions.itemPositions.value
                            .where((p) => p.index == 0)
                            .any((p) => p.itemLeadingEdge >= 0) &&
                        _hasMore &&
                        !_loading) {
                      _loadMessages();
                    }
                    return false;
                  },
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _scrollController,
                    itemPositionsListener: _positions,
                    initialScrollIndex: _items.isNotEmpty ? _items.length - 1 : 0,
                    itemCount: _items.length,
                    itemBuilder: _buildItem,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(hintText: 'Type a message'),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Positioned(
          //   top: 12,
          //   left: 0,
          //   right: 0,
          //   child: ValueListenableBuilder<String?>(
          //     valueListenable: _floatingDate,
          //     builder: (context, value, _) {
          //       if (value == null) return const SizedBox.shrink();
          //       return Center(
          //         child: Container(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 12, vertical: 4),
          //           decoration: BoxDecoration(
          //             color: Theme.of(context).colorScheme.surfaceContainerHighest,
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: Text(
          //             value,
          //             style: Theme.of(context).textTheme.labelSmall,
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}
