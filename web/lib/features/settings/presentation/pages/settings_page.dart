import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/site_settings.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/settings_general_section.dart';
import '../widgets/settings_integration_section.dart';
import '../widgets/settings_maintenance_section.dart';
import '../widgets/settings_seo_section.dart';

/// Halaman pengaturan situs.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _formKey = GlobalKey<FormState>();

  // General
  final _siteNameController = TextEditingController();
  final _siteDescriptionController = TextEditingController();
  final _siteUrlController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _faviconUrlController = TextEditingController();

  // SEO
  final _defaultMetaTitleController = TextEditingController();
  final _defaultMetaDescriptionController = TextEditingController();
  final _defaultOgImageController = TextEditingController();

  // Appearance
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();
  final _footerTextController = TextEditingController();

  // Integration
  final _googleAnalyticsIdController = TextEditingController();
  final _customHeadCodeController = TextEditingController();
  final _customBodyCodeController = TextEditingController();

  // Maintenance
  final _maintenanceMessageController = TextEditingController();
  bool _maintenanceMode = false;

  /// ID pengaturan yang sedang diedit.
  String _settingsId = '';

  /// Tanggal terakhir diperbarui.
  DateTime _updatedAt = DateTime.now();

  @override
  void dispose() {
    _siteNameController.dispose();
    _siteDescriptionController.dispose();
    _siteUrlController.dispose();
    _logoUrlController.dispose();
    _faviconUrlController.dispose();
    _defaultMetaTitleController.dispose();
    _defaultMetaDescriptionController.dispose();
    _defaultOgImageController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _footerTextController.dispose();
    _googleAnalyticsIdController.dispose();
    _customHeadCodeController.dispose();
    _customBodyCodeController.dispose();
    _maintenanceMessageController.dispose();
    super.dispose();
  }

  void _populateForm(SiteSettings settings) {
    _settingsId = settings.id;
    _updatedAt = settings.updatedAt;
    _siteNameController.text = settings.siteName;
    _siteDescriptionController.text = settings.siteDescription ?? '';
    _siteUrlController.text = settings.siteUrl ?? '';
    _logoUrlController.text = settings.logoUrl ?? '';
    _faviconUrlController.text = settings.faviconUrl ?? '';
    _defaultMetaTitleController.text = settings.defaultMetaTitle ?? '';
    _defaultMetaDescriptionController.text =
        settings.defaultMetaDescription ?? '';
    _defaultOgImageController.text = settings.defaultOgImage ?? '';
    _primaryColorController.text = settings.primaryColor ?? '';
    _secondaryColorController.text = settings.secondaryColor ?? '';
    _footerTextController.text = settings.footerText ?? '';
    _googleAnalyticsIdController.text = settings.googleAnalyticsId ?? '';
    _customHeadCodeController.text = settings.customHeadCode ?? '';
    _customBodyCodeController.text = settings.customBodyCode ?? '';
    _maintenanceMessageController.text = settings.maintenanceMessage ?? '';
    _maintenanceMode = settings.maintenanceMode;
  }

  SiteSettings _buildSettingsFromForm() {
    return SiteSettings(
      id: _settingsId,
      siteName: _siteNameController.text.trim(),
      siteDescription: _siteDescriptionController.text.trim().isNotEmpty
          ? _siteDescriptionController.text.trim()
          : null,
      siteUrl: _siteUrlController.text.trim().isNotEmpty
          ? _siteUrlController.text.trim()
          : null,
      logoUrl: _logoUrlController.text.trim().isNotEmpty
          ? _logoUrlController.text.trim()
          : null,
      faviconUrl: _faviconUrlController.text.trim().isNotEmpty
          ? _faviconUrlController.text.trim()
          : null,
      defaultMetaTitle: _defaultMetaTitleController.text.trim().isNotEmpty
          ? _defaultMetaTitleController.text.trim()
          : null,
      defaultMetaDescription:
          _defaultMetaDescriptionController.text.trim().isNotEmpty
              ? _defaultMetaDescriptionController.text.trim()
              : null,
      defaultOgImage: _defaultOgImageController.text.trim().isNotEmpty
          ? _defaultOgImageController.text.trim()
          : null,
      primaryColor: _primaryColorController.text.trim().isNotEmpty
          ? _primaryColorController.text.trim()
          : null,
      secondaryColor: _secondaryColorController.text.trim().isNotEmpty
          ? _secondaryColorController.text.trim()
          : null,
      footerText: _footerTextController.text.trim().isNotEmpty
          ? _footerTextController.text.trim()
          : null,
      googleAnalyticsId: _googleAnalyticsIdController.text.trim().isNotEmpty
          ? _googleAnalyticsIdController.text.trim()
          : null,
      customHeadCode: _customHeadCodeController.text.trim().isNotEmpty
          ? _customHeadCodeController.text.trim()
          : null,
      customBodyCode: _customBodyCodeController.text.trim().isNotEmpty
          ? _customBodyCodeController.text.trim()
          : null,
      maintenanceMode: _maintenanceMode,
      maintenanceMessage: _maintenanceMessageController.text.trim().isNotEmpty
          ? _maintenanceMessageController.text.trim()
          : null,
      updatedAt: _updatedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: _onStateChanged,
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (settings) => _buildForm(context, settings),
        saving: (settings) => _buildForm(context, settings, isSaving: true),
        saved: (settings) => _buildForm(context, settings),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    state.whenOrNull(
      loaded: (settings) => _populateForm(settings),
      saved: (settings) {
        _populateForm(settings);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsSaved),
            backgroundColor: AppColors.success,
          ),
        );
      },
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    SiteSettings settings, {
    bool isSaving = false,
  }) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isSaving),
            const SizedBox(height: AppDimensions.spacingL),
            SettingsGeneralSection(
              siteNameController: _siteNameController,
              siteDescriptionController: _siteDescriptionController,
              siteUrlController: _siteUrlController,
              logoUrlController: _logoUrlController,
              faviconUrlController: _faviconUrlController,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SettingsSeoSection(
              defaultMetaTitleController: _defaultMetaTitleController,
              defaultMetaDescriptionController:
                  _defaultMetaDescriptionController,
              defaultOgImageController: _defaultOgImageController,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SettingsAppearanceSection(
              primaryColorController: _primaryColorController,
              secondaryColorController: _secondaryColorController,
              footerTextController: _footerTextController,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SettingsIntegrationSection(
              googleAnalyticsIdController: _googleAnalyticsIdController,
              customHeadCodeController: _customHeadCodeController,
              customBodyCodeController: _customBodyCodeController,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            SettingsMaintenanceSection(
              maintenanceMode: _maintenanceMode,
              onMaintenanceModeChanged: (value) {
                setState(() => _maintenanceMode = value);
              },
              maintenanceMessageController: _maintenanceMessageController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSaving) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.settingsTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: isSaving ? null : _onSave,
          icon: isSaving
              ? const SizedBox(
                  width: AppDimensions.iconS,
                  height: AppDimensions.iconS,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(isSaving ? AppStrings.loading : AppStrings.save),
        ),
      ],
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final settings = _buildSettingsFromForm();
      context.read<SettingsCubit>().saveSettings(settings);
    }
  }

  Widget _buildError(BuildContext context, String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.avatarL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () =>
                  context.read<SettingsCubit>().loadSettings(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
}
