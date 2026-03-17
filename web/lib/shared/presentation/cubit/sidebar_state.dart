part of 'sidebar_cubit.dart';

/// State untuk sidebar CMS.
@freezed
sealed class SidebarState with _$SidebarState {
  const factory SidebarState({
    /// Apakah sidebar dalam kondisi collapsed (hanya icon).
    @Default(false) bool isCollapsed,

    /// Route yang sedang aktif.
    @Default('/dashboard') String activeRoute,

    /// Section yang sedang expanded.
    @Default({'content', 'pages'}) Set<String> expandedSections,

    /// Daftar domain definition untuk dynamic sidebar.
    @Default([]) List<DomainDefinition> domains,
  }) = _SidebarState;
}
