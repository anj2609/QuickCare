import 'package:flutter/material.dart';

const _kBg = Color(0xFFF0F4F8);
const _kCardBg = Colors.white;
const _kPrimary = Color(0xFF2CB8C7);
const _kPrimaryDark = Color(0xFF1A92A0);
const _kNavy = Color(0xFF0F172A);
const _kGrey = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

/// Floating AI chat button + slide-in chat panel.
class AiChatOverlay extends StatefulWidget {
  final String userName;
  const AiChatOverlay({super.key, this.userName = ''});

  @override
  State<AiChatOverlay> createState() => _AiChatOverlayState();
}

class _AiChatOverlayState extends State<AiChatOverlay>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Simple local chat history
  final List<_ChatMsg> _messages = [];
  bool _typing = false;

  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _animCtrl.forward();
      if (_messages.isEmpty) {
        final first = widget.userName.trim().split(' ').first;
        final name = first.isNotEmpty ? first : 'there';
        _messages.add(
          _ChatMsg(
            text:
                "Hello $name! I'm your QuickCare AI Assistant. How can I help you today?",
            isBot: true,
          ),
        );
      }
    } else {
      _animCtrl.reverse();
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text: text, isBot: false));
      _ctrl.clear();
      _typing = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          _ChatMsg(
            text:
                "Thanks for your question! This feature is coming soon. For emergencies, please call 911 immediately.",
            isBot: true,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Scrim ────────────────────────────────────────────────
        if (_open)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: GestureDetector(
                onTap: _toggle,
                child: Container(color: Colors.black38),
              ),
            ),
          ),

        // ── Chat panel ───────────────────────────────────────────
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: MediaQuery.of(context).size.width * 0.85,
          child: SlideTransition(
            position: _slideAnim,
            child: Material(
              color: _kBg,
              elevation: 16,
              shadowColor: Colors.black26,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildDisclaimer(),
                    Expanded(child: _buildMessages()),
                    _buildInput(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── FAB ──────────────────────────────────────────────────
        Positioned(right: 16, bottom: 16, child: _buildFab()),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        color: _kCardBg,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimary, _kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QuickCare AI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Online — Medical Assistant',
                      style: TextStyle(fontSize: 11, color: _kGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _toggle,
            icon: const Icon(Icons.close, color: _kGrey, size: 20),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // ── Disclaimer ─────────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI may generate inaccurate responses. For emergencies, call 911 immediately.',
              style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages ───────────────────────────────────────────────────────────────
  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: _messages.length + (_typing ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length && _typing) return _buildTypingIndicator();
        return _buildBubble(_messages[i]);
      },
    );
  }

  Widget _buildBubble(_ChatMsg msg) {
    final isBot = msg.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimary, _kPrimaryDark],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? _kCardBg : _kPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isBot ? 4 : 14),
                  bottomRight: Radius.circular(isBot ? 14 : 4),
                ),
                border: Border.all(
                  color: isBot ? _kBorder : _kPrimary.withValues(alpha: 0.2),
                ),
                boxShadow: isBot
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isBot ? _kNavy : _kPrimaryDark,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimary, _kPrimaryDark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600 + i * 200),
                  builder: (_, v, child) => Opacity(
                    opacity: (v * 2 - 1).abs().clamp(0.3, 1.0),
                    child: child,
                  ),
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: _kGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input ──────────────────────────────────────────────────────────────────
  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: const BoxDecoration(
        color: _kCardBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _kBorder),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 13, color: _kNavy),
                decoration: const InputDecoration(
                  hintText: 'Ask a health question...',
                  hintStyle: TextStyle(fontSize: 13, color: _kGrey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimary, _kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: _open
              ? null
              : const LinearGradient(
                  colors: [_kPrimary, _kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: _open ? _kGrey : null,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: _open ? 0 : 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _open
              ? const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                  key: ValueKey('close'),
                )
              : const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                  key: ValueKey('ai'),
                ),
        ),
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isBot;
  _ChatMsg({required this.text, required this.isBot});
}
