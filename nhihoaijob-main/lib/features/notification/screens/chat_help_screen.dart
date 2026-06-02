import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatHelpScreen extends StatefulWidget {
  const ChatHelpScreen({super.key});

  @override
  State<ChatHelpScreen> createState() => _ChatHelpScreenState();
}

class _ChatHelpScreenState extends State<ChatHelpScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    // Đọc chính xác tên biến mới NEW_GEMINI_KEY từ file .env
    final apiKey = dotenv.env['NEW_GEMINI_KEY'] ?? '';
    
    // Log kiểm tra trong tab Debug Console xem Web đã nạp thành công Key chưa
    debugPrint("=== [GEMINI CHECK] API KEY HIỆN TẠI: $apiKey ===");
    
    // Khởi tạo model gemini-2.0-flash với chỉ dẫn hệ thống chuẩn
    _model = GenerativeModel(
      model: 'gemini-2.0-flash', 
      apiKey: apiKey,
      systemInstruction: Content.system('chat_help.ai_prompt'.tr()),
    );
    
    // Khởi tạo phiên hội thoại trống, bảo mật và đúng rule cấu trúc tin nhắn
    _chatSession = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final aiText = response.text ?? 'chat_help.error_default'.tr();
      setState(() => _messages.add({"role": "ai", "text": aiText}));
    } catch (e) {
      setState(() => _messages.add({"role": "ai", "text": '${'chat_help.error_connection'.tr()} $e'}));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("chat_help.title".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8), 
              child: Text("chat_help.thinking".tr(), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    decoration: InputDecoration(hintText: 'chat_help.hint'.tr()), 
                    onSubmitted: (_) {
                      if (!_isLoading) _sendMessage();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage, 
                  icon: const Icon(Remix.send_plane_fill, color: Colors.orange)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, String> msg) {
    final bool isUser = msg["role"] == "user";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(radius: 18, backgroundColor: Colors.red[700], child: const Icon(Remix.qq_fill, color: Colors.white, size: 20)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: BoxDecoration(
                color: isUser ? Colors.orange[800] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), 
                  topRight: const Radius.circular(16), 
                  bottomLeft: Radius.circular(isUser ? 16 : 4), 
                  bottomRight: Radius.circular(isUser ? 4 : 16)
                ),
              ),
              child: Text(msg["text"] ?? "", style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}