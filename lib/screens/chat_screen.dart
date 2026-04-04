import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/weather_model.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final WeatherModel? weather;
  const ChatScreen({super.key, this.weather});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  static const List<String> _suggestions = [
    '🌂 Do I need an umbrella?',
    '👕 What should I wear?',
    '🏃 Good day for a run?',
    '🌙 How\'s tonight looking?',
    '📅 Best day this week?',
  ];

  Color get _accent {
    if (widget.weather == null) return const Color(0xFF7C6FFF);
    final c = widget.weather!.condition.toLowerCase();
    if (c.contains('clear') || c.contains('sun')) return const Color(0xFFFB923C);
    if (c.contains('rain') || c.contains('drizzle')) return const Color(0xFF22D3EE);
    if (c.contains('thunder') || c.contains('storm')) return const Color(0xFFFF4D6D);
    if (c.contains('snow')) return const Color(0xFF93C5FD);
    if (c.contains('cloud')) return const Color(0xFF94A3B8);
    return const Color(0xFF7C6FFF);
  }

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      content: widget.weather != null
          ? "Hey! I'm VibeCast AI 🤖\nI know it's **${widget.weather!.temperature}°C** with **${widget.weather!.condition}** in **${widget.weather!.city}** right now. Ask me anything!"
          : "Hey! I'm VibeCast AI 🤖\nSearch a city on the Weather tab first — then I'll know your local weather and can actually help you.",
      role: MessageRole.assistant,
    ));
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weather != null && oldWidget.weather == null) {
      setState(() {
        _messages.add(ChatMessage(
          content:
              "Just got your location data 📍 — it's **${widget.weather!.temperature}°C** and **${widget.weather!.condition}** in **${widget.weather!.city}**. What do you wanna know?",
          role: MessageRole.assistant,
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (widget.weather == null) {
      setState(() {
        _messages.add(ChatMessage(
          content: "Go search a city on the Weather tab first! I need weather data to help you 🌍",
          role: MessageRole.assistant,
        ));
      });
      _scrollToBottom();
      return;
    }

    final userMsg = ChatMessage(content: text.trim(), role: MessageRole.user);
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m != _messages.first && m != userMsg)
          .toList();
      final reply = await _chatService.sendMessage(
        message: text.trim(),
        weather: widget.weather!,
        history: history,
      );
      setState(() {
        _messages.add(ChatMessage(content: reply, role: MessageRole.assistant));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: "Something went wrong, try again? 😅",
          role: MessageRole.assistant,
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length && _isTyping) {
                  return _buildTyping();
                }
                return _buildBubble(_messages[i]);
              },
            ),
          ),
          if (_messages.length <= 2 && widget.weather != null)
            _buildSuggestions(),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF08080F),
        border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent, _accent.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VibeCast AI',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3)),
              Text(
                widget.weather != null
                    ? '${widget.weather!.city} · ${widget.weather!.temperature}°C · ${widget.weather!.condition}'
                    : 'Search a city to activate',
                style: const TextStyle(fontSize: 11, color: Colors.white38),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (_messages.length > 1)
          GestureDetector(
            onTap: () => setState(() => _messages.removeRange(1, _messages.length)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: const Text('Clear',
                  style: TextStyle(fontSize: 12, color: Colors.white38)),
            ),
          ),
      ]),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _sendMessage(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111120),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _accent.withOpacity(0.25)),
            ),
            child: Text(_suggestions[i],
                style: TextStyle(fontSize: 12, color: _accent)),
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF08080F),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111120),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: 'Ask about the weather...',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _sendMessage(_inputController.text),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent, _accent.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                    color: _accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accent, _accent.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 13))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [_accent, _accent.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : const Color(0xFF111120),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                            color: _accent.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : Colors.white.withOpacity(0.82),
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Icon(Icons.person_rounded,
                      color: Colors.white38, size: 15)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_accent, _accent.withOpacity(0.5)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 13))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111120),
              borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: const Radius.circular(4)),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _typingDot(0),
              const SizedBox(width: 5),
              _typingDot(200),
              const SizedBox(width: 5),
              _typingDot(400),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _typingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
            color: _accent, shape: BoxShape.circle),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
