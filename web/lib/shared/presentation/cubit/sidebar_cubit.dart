import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../features/domain_builder/domain/entities/domain_definition.dart';
import '../../../features/domain_builder/domain/usecases/get_domains_usecase.dart';

part 'sidebar_state.dart';
part 'sidebar_cubit.freezed.dart';

/// Cubit untuk mengelola state sidebar CMS.
class SidebarCubit extends Cubit<SidebarState> {
  final GetDomainsUseCase _getDomainsUseCase;

  SidebarCubit({
    required GetDomainsUseCase getDomainsUseCase,
  })  : _getDomainsUseCase = getDomainsUseCase,
        super(const SidebarState()) {
    loadDomains();
  }

  /// Toggle sidebar collapsed/expanded.
  void toggleCollapse() {
    emit(state.copyWith(isCollapsed: !state.isCollapsed));
  }

  /// Set sidebar ke collapsed.
  void collapse() {
    emit(state.copyWith(isCollapsed: true));
  }

  /// Set sidebar ke expanded.
  void expand() {
    emit(state.copyWith(isCollapsed: false));
  }

  /// Set route yang aktif.
  void selectRoute(String route) {
    emit(state.copyWith(activeRoute: route));
  }

  /// Memuat daftar domain untuk dynamic sidebar.
  Future<void> loadDomains() async {
    final result = await _getDomainsUseCase();
    result.fold(
      (_) {}, // Gagal load domain, sidebar tetap tampil menu statis.
      (domains) => emit(state.copyWith(domains: domains)),
    );
  }

  /// Toggle expand/collapse section tertentu.
  void toggleSection(String sectionKey) {
    final sections = Set<String>.from(state.expandedSections);
    if (sections.contains(sectionKey)) {
      sections.remove(sectionKey);
    } else {
      sections.add(sectionKey);
    }
    emit(state.copyWith(expandedSections: sections));
  }
}
