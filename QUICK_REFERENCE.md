// ============================================================
// FULL STATE MANAGER - CHEAT SHEET
// ============================================================

// 1️⃣ DataState - Define your app's data
class YourDataState extends DataState {
  final String? name;
  // Implement: copyWith(), copyWithOptional(), reset()
}

// 2️⃣ BaseCubit - Handle business logic
class YourCubit extends BaseCubit<YourDataState> {
  // Page-level (entire screen)
  emitPageLoading()                    // Show full page loading
  emitPageSuccess()                    // Show page success
  emitPageError(failure)               // Show page error
  executePageApiCall()                 // API call with page loading
  
  // Widget-level (specific parts)
  emitWidgetLoading('key')            // Load specific widget
  emitWidgetSuccess('key', data)      // Widget success
  emitWidgetError('key', failure)     // Widget error
  executeWidgetApiCall(widgetKey)     // API call for widget
  
  // Data operations
  updateData((state) => ...)          // Update your data
  setData(newData)                    // Replace data
  resetData()                          // Reset to initial
}

// 3️⃣ BaseScreen - Screen with automatic state handling
class YourScreen extends BaseScreen<YourCubit, YourDataState> {
  @override
  Widget buildContent(context, data) => YourWidget(data);
  
  // Optional configs:
  bool get enablePullToRefresh => true;     // Pull to refresh
  bool get useLoadingOverlay => false;      // Overlay vs replace
  bool get showErrorAsSnackBar => true;     // Error display
}

// 4️⃣ ScreenWrapper - Wrap any widget with state management
ScreenWrapper<YourCubit, YourDataState>(
  builder: (context, data) => YourWidget(data),
  loadingBuilder: (context) => LoadingWidget(),    // Optional
  errorBuilder: (context, failure) => ErrorWidget(), // Optional
)

// 5️⃣ WidgetStateBuilder - Individual widget loading states
WidgetStateBuilder<YourCubit, YourDataState, DataType>(
  widgetKey: 'unique_key',
  onSuccess: (context, data) => SuccessWidget(data),
  onLoading: (context) => LoadingWidget(),          // Optional
  onError: (context, failure) => ErrorWidget(),     // Optional
)

// 6️⃣ Optional - Make fields nullable in copyWith
copyWithOptional(
  name: Optional.value('John'),    // Set value
  email: Optional.null_(),         // Clear (set to null)
  // age not mentioned = unchanged
)

// 7️⃣ BaseState - The unified state (auto-managed)
state.pageStatus              // loading, success, error, initial
state.data                    // Your app data
state.widgetStates['key']     // Individual widget states
state.isPageLoading           // Check page loading
state.isWidgetLoading('key')  // Check widget loading

// ============================================================
// QUICK EXAMPLE
// ============================================================

// 1. Define data
class UserDataState extends DataState {
  final User? user;
  final List<Post>? posts;
}

// 2. Create cubit
class UserCubit extends BaseCubit<UserDataState> {
  static const postsWidget = 'posts';
  
  // Load entire page
  loadUser() => executePageApiCall(
    apiCall: () => api.getUser(),
    onSuccess: (user) => updateData((s) => s.copyWith(user: user)),
  );
  
  // Load just posts widget
  loadPosts() => executeWidgetApiCall(
    widgetKey: postsWidget,
    apiCall: () => api.getPosts(),
  );
  
  // Logout (clear user)
  logout() => updateData((s) => s.copyWithOptional(
    user: Optional.null_(),
  ));
}

// 3. Build screen
class UserScreen extends BaseScreen<UserCubit, UserDataState> {
  @override
  Widget buildContent(context, data) {
    return Column(
      children: [
        if (data.user != null) UserCard(data.user!),
        
        // Posts with separate loading
        WidgetStateBuilder<UserCubit, UserDataState, List<Post>>(
          widgetKey: UserCubit.postsWidget,
          onSuccess: (_, posts) => PostsList(posts),
          onLoading: (_) => CircularProgressIndicator(),
        ),
      ],
    );
  }
  
  @override
  bool get enablePullToRefresh => true;
  
  @override
  onRefresh(context) => context.read<UserCubit>().loadUser();
}

// 4. Use in app
BlocProvider(
  create: (_) => UserCubit()..loadUser(),
  child: UserScreen(),
)

// ============================================================
// KEY CONCEPTS
// ============================================================

/*
📦 PACKAGE PROVIDES:
• Page-level states (loading/success/error for entire screen)
• Widget-level states (loading/success/error for parts)
• Data management (with nullable copyWith support)
• Automatic error handling (dialogs/snackbars)
• Pull-to-refresh support
• Loading overlays

🎯 WHEN TO USE:
• Page loading: User opens screen → Show skeleton → Show content
• Widget loading: Load comments separately from main content
• Data updates: Form submissions, user actions
• Error handling: Network failures, validation errors

💡 BENEFITS:
• No manual loading/error state management
• Consistent UI patterns across app
• Separate loading for different screen parts
• Clean separation of logic (Cubit) and UI (Screen)
*/