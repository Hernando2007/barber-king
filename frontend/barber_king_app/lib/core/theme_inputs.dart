part of 'theme.dart';

InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      labelStyle: const TextStyle(color: AppColors.subtitle),
      floatingLabelStyle: const TextStyle(color: AppColors.primary),
      hintStyle: const TextStyle(color: AppColors.muted),
      helperStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.subtitle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    );

ChipThemeData get _chipTheme => ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: .18),
      disabledColor: AppColors.surfaceAlt,
      labelStyle: const TextStyle(color: AppColors.subtitle),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );

PopupMenuThemeData get _popupMenuTheme => PopupMenuThemeData(
      color: AppColors.surfaceAlt,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      textStyle: const TextStyle(color: AppColors.white),
    );

ProgressIndicatorThemeData get _progressIndicatorTheme =>
    const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceAlt,
      circularTrackColor: AppColors.surfaceAlt,
    );

NavigationBarThemeData get _navigationBarTheme => NavigationBarThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: .16),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.subtitle,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.subtitle,
          size: 23,
        ),
      ),
    );

DatePickerThemeData get _datePickerTheme => DatePickerThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.surface,
      headerForegroundColor: AppColors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.black
            : AppColors.white,
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      todayForegroundColor: const WidgetStatePropertyAll(AppColors.primary),
      todayBorder: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );

TimePickerThemeData get _timePickerTheme => TimePickerThemeData(
      backgroundColor: AppColors.card,
      dialBackgroundColor: AppColors.surface,
      dialHandColor: AppColors.primary,
      hourMinuteColor: AppColors.surface,
      hourMinuteTextColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );

TextSelectionThemeData get _textSelectionTheme =>
    const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: Color(0x55D6B25E),
      selectionHandleColor: AppColors.primary,
    );

ScrollbarThemeData get _scrollbarTheme => ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(
        AppColors.subtitle.withValues(alpha: .35),
      ),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(5),
    );
