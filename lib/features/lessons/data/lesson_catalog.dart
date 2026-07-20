import '../models/lesson.dart';
import '../models/lesson_requirement.dart';
import '../models/lesson_step.dart';

abstract final class LessonCatalog {
  static const categories = ['用户系统', '帖子系统', '聊天系统', '个人资料', '通知系统'];

  static final lessons = <Lesson>[
    _createPostLesson,
    _comingSoon('post-list', '帖子列表', '展示实时帖子流、加载状态与空状态。', '帖子系统',
        ['UI', 'Firestore'], ['发布文字帖子']),
    _comingSoon('post-detail', '帖子详情', '组合帖子正文、作者和互动区域。', '帖子系统', ['UI', '路由'],
        ['帖子列表']),
    _comingSoon('like-post', '点赞功能', '实现点赞写入、取消点赞和状态同步。', '帖子系统',
        ['逻辑', 'Firebase'], ['帖子列表']),
    _comingSoon('comments', '评论功能', '创建评论、展示评论列表并维护计数。', '帖子系统',
        ['UI', '逻辑', 'Firebase'], ['帖子详情']),
    _comingSoon('delete-post', '删除帖子', '实现权限判断、确认提示和安全删除。', '帖子系统',
        ['逻辑', 'Firebase'], ['发布文字帖子']),
    _comingSoon('register', '用户注册', '完成注册表单、校验和 Firebase Auth 注册。', '用户系统',
        ['UI', 'FirebaseAuth'], const []),
    _comingSoon('login', '用户登录', '实现登录表单、异常反馈和会话进入。', '用户系统',
        ['UI', 'FirebaseAuth'], ['用户注册']),
    _comingSoon('chat', '私信聊天', '实现会话列表、消息发送和实时消息流。', '聊天系统',
        ['UI', 'Firestore'], ['用户登录']),
    _comingSoon('profile', '个人主页', '组合用户资料、帖子统计和个人帖子列表。', '个人资料',
        ['UI', 'Firestore'], ['帖子列表', '用户登录']),
  ];

  static final _createPostLesson = Lesson(
    id: 'create-text-post-advanced-images',
    title: '发布文字帖子',
    description: '按页面输入、提交逻辑和 Firebase 写入三个核心部分完成发帖功能。',
    difficulty: '高级图片版',
    category: '帖子系统',
    tags: const ['UI', '逻辑', 'Firebase', 'Storage'],
    estimatedMinutes: 90,
    prerequisites: const ['理解 StatefulWidget', '了解 async/await'],
    version: LessonVersion.advancedImages,
    steps: [
      LessonStep(
        id: 'create-post-part-1',
        part: 'Part 1：发帖页面输入',
        title: '页面输入',
        instruction: '完成 TextEditingController、TextField 和发布按钮的页面输入区域。',
        stepType: LessonStepType.ui,
        explanation: '本部分只构建可运行的声明式 UI。CreatePostPage 作者答案尚未提供。',
        starterCode: "Column(children: [Text('发布帖子')])",
        standardAnswerAssets: const {
          'create_post_page.dart':
      'assets/lessons/create_post/advanced_images/answers/create_post_page_ui.dart',
        },
        hints: const ['先完成输入框和按钮的可视结构，再点击“运行”查看当前代码。'],
        requirements: const [
          RequiredWidgetRequirement('Column'),
          RequiredWidgetRequirement('TextField'),
          RequiredWidgetRequirement('ElevatedButton'),
          RequiredTextRequirement('发布'),
        ],
        relatedFiles: const ['create_post_page.dart'],
        checkMode: CheckMode.uiAst,
      ),
      LessonStep(
        id: 'create-post-part-2',
        part: 'Part 2：点击发布按钮的逻辑',
        title: '点击提交逻辑',
        instruction: '实现 _publishPost、输入清理、校验、防重复提交和 mounted 安全处理。',
        stepType: LessonStepType.logic,
        explanation: '检查使用 Dart AST，不执行代码。_publishPost 作者答案尚未提供。',
        starterCode: 'class _CreatePostPageState {\n}\n',
        standardAnswerAssets: const {
          'create_post_page.dart':
      'assets/lessons/create_post/advanced_images/answers/create_post_page_logic.dart',
        },
        hints: const ['把 trim、空内容判断、提交状态和 service 调用分别补齐。'],
        requirements: const [
          RequiredMethodRequirement('_publishPost'),
          RequiredFieldRequirement('_isSubmitting'),
          RequiredTrimRequirement(),
          RequiredIfRequirement(),
          RequiredAwaitRequirement(),
          RequiredMethodCallRequirement('createPost'),
          RequiredCodeIdentifierRequirement('mounted'),
        ],
        relatedFiles: const ['create_post_page.dart'],
        checkMode: CheckMode.dartAst,
      ),
      LessonStep(
        id: 'create-post-part-3',
        part: 'Part 3：Firebase 数据写入',
        title: 'Firebase 数据写入',
        instruction: '实现带多图上传、失败清理和作者资料读取的 PostService.createPost。',
        stepType: LessonStepType.firebase,
        explanation:
            '该部分属于 advancedImages。作者 PostService 源文件当前未附加，因此答案仓库会显示尚未录入。',
        starterCode: 'class PostService {\n}\n',
        standardAnswerAssets: const {
          'post_service.dart':
              'assets/lessons/create_post/advanced_images/answers/post_service.dart',
        },
        hints: const ['按 Auth、Storage 上传、Firestore 写入、失败回滚四段检查结构。'],
        requirements: const [
          RequiredClassRequirement('PostService'),
          RequiredMethodRequirement('createPost'),
          RequiredMethodRequirement('_getCurrentAuthorName'),
          RequiredCurrentUserRequirement(),
          RequiredTrimRequirement(),
          RequiredCodeIdentifierRequirement('imageFiles'),
          RequiredIntegerLiteralRequirement(1000),
          RequiredIntegerLiteralRequirement(9),
          RequiredMethodCallRequirement('putFile'),
          RequiredMethodCallRequirement('getDownloadURL'),
          RequiredCollectionRequirement('posts'),
          RequiredMapFieldsRequirement([
            'authorId',
            'authorName',
            'content',
            'createdAt',
            'likeCount',
            'isPrivate',
            'imageUrls',
            'imagePaths',
          ]),
          RequiredMethodCallRequirement('delete'),
          RequiredRethrowRequirement(),
        ],
        relatedFiles: const ['post_service.dart'],
        checkMode: CheckMode.dartAst,
      ),
    ],
  );

  static Lesson _comingSoon(
    String id,
    String title,
    String description,
    String category,
    List<String> tags,
    List<String> prerequisites,
  ) =>
      Lesson(
        id: id,
        title: title,
        description: description,
        difficulty: '即将推出',
        category: category,
        tags: tags,
        estimatedMinutes: 60,
        prerequisites: prerequisites,
        comingSoon: true,
        steps: const [],
      );
}
