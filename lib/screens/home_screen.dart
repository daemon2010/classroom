import "dart:async";

import "package:flutter/material.dart";

import "../app.dart";
import "../models/classroom_models.dart";
import "../services/report_controller.dart";
import "../widgets/course_filter.dart";
import "../widgets/report_table.dart";
import "../widgets/status_panel.dart";
import "../widgets/summary_cards.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.services, super.key});

  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ReportController _controller;
  String? _selectedCourseId;
  String _searchQuery = "";
  bool _onlyTurnedIn = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.services.reportController;
    final settings = widget.services.settings.settings;
    _selectedCourseId = settings.lastSelectedCourseId;
    _onlyTurnedIn = settings.onlyTurnedIn;
    _controller.addListener(_handleControllerChanged);
    widget.services.settings.addListener(_handleSettingsChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.services.reportController !=
        widget.services.reportController) {
      _controller.removeListener(_handleControllerChanged);
      _controller = widget.services.reportController;
      _controller.addListener(_handleControllerChanged);
    }

    if (oldWidget.services.settings != widget.services.settings) {
      oldWidget.services.settings.removeListener(_handleSettingsChanged);
      widget.services.settings.addListener(_handleSettingsChanged);
      _handleSettingsChanged();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    widget.services.settings.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _filteredRows(_controller.snapshot.rows);
    final filteredSummary = _summaryFor(filteredRows);
    final isSignedIn = _controller.isSignedIn;
    final lastError = _controller.lastError;
    final settings = widget.services.settings.settings;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onSettings: _openSettings),
            const SizedBox(height: 14),
            StatusPanel(
              authStatus: _controller.authStatus,
              lastChecked: _controller.lastChecked,
              ungradedCount: filteredRows.length,
            ),
            if (!isSignedIn) ...[
              const SizedBox(height: 10),
              const _ConnectHint(),
            ],
            if (lastError != null && lastError.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ErrorHint(message: lastError),
            ],
            const SizedBox(height: 12),
            _ActionBar(
              isSignedIn: isSignedIn,
              isLoading: _controller.isRefreshing,
              canExport: filteredRows.isNotEmpty && !_controller.isRefreshing,
              onSignIn: _connect,
              onCheckNow: _refreshReport,
              onExportCsv: _exportCsv,
              onSettings: _openSettings,
            ),
            const SizedBox(height: 12),
            CourseFilter(
              courses: _controller.courses,
              selectedCourseId: _selectedCourseId,
              onlyTurnedIn: _onlyTurnedIn,
              searchQuery: _searchQuery,
              onCourseChanged: (courseId) {
                setState(() {
                  _selectedCourseId = courseId;
                });
                unawaited(
                  widget.services.settings.setLastSelectedCourseId(courseId),
                );
              },
              onOnlyTurnedInChanged: (value) {
                setState(() {
                  _onlyTurnedIn = value;
                });
                unawaited(widget.services.settings.setOnlyTurnedIn(value));
              },
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            SummaryCards(summary: filteredSummary),
            const SizedBox(height: 12),
            Expanded(
              child: ReportTable(
                rows: filteredRows,
                showStudentEmailColumn: settings.showStudentEmailColumn,
                showLateColumn: settings.showLateColumn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      final validSelection = _validCourseSelection(_controller.courses);
      if (validSelection != _selectedCourseId) {
        unawaited(
          widget.services.settings.setLastSelectedCourseId(validSelection),
        );
      }
      _selectedCourseId = validSelection;
    });
  }

  void _handleSettingsChanged() {
    if (!mounted) {
      return;
    }

    final settings = widget.services.settings.settings;
    setState(() {
      _onlyTurnedIn = settings.onlyTurnedIn;
      if (!settings.rememberLastSelectedCourse) {
        _selectedCourseId = null;
      } else {
        _selectedCourseId = _validCourseSelection(_controller.courses);
      }
    });
  }

  Future<void> _connect() async {
    final connected = await _controller.signIn();
    if (!mounted || connected) {
      return;
    }

    _showMessage(_controller.lastError ?? "Google sign-in could not finish.");
  }

  Future<void> _refreshReport() async {
    final refreshed = await _controller.refreshReport();
    if (!mounted || refreshed) {
      return;
    }

    _showMessage(_controller.lastError ?? "Classroom check could not finish.");
  }

  List<UngradedSubmissionReportRow> _filteredRows(
    List<UngradedSubmissionReportRow> rows,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return rows
        .where((row) {
          if (_selectedCourseId != null && row.courseId != _selectedCourseId) {
            return false;
          }

          if (_onlyTurnedIn &&
              row.submissionState != SubmissionState.turnedIn) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          return [
            row.studentName,
            row.studentEmail,
            row.courseName,
            row.subject,
            row.assignmentTitle,
          ].whereType<String>().any(
            (value) => value.toLowerCase().contains(query),
          );
        })
        .toList(growable: false);
  }

  ReportSummary _summaryFor(List<UngradedSubmissionReportRow> rows) {
    return ReportSummary(
      courseCount: _controller.courses.length,
      assignmentCount: rows.map((row) => row.courseWorkId).toSet().length,
      ungradedSubmissionCount: rows.length,
      classesWithUngradedCount: rows.map((row) => row.courseId).toSet().length,
      lateSubmissionCount: rows.where((row) => row.isLate).length,
    );
  }

  String? _validCourseSelection(List<ClassroomCourse> courses) {
    final selectedCourseId = _selectedCourseId;
    if (selectedCourseId == null) {
      return null;
    }

    return courses.any((course) => course.id == selectedCourseId)
        ? selectedCourseId
        : null;
  }

  Future<void> _exportCsv() async {
    final exportedPath = await _controller.exportCsv(
      rows: _filteredRows(_controller.snapshot.rows),
      refreshIfNeeded: false,
    );
    if (!mounted) {
      return;
    }

    if (exportedPath == null) {
      final error = _controller.lastError;
      if (error != null && error.isNotEmpty) {
        _showMessage(error);
      }
      return;
    }

    _showMessage("CSV exported successfully.");
  }

  void _openSettings() {
    Navigator.of(context).pushNamed("/settings");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Classroom Ungraded Checker",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton(
          tooltip: "Settings",
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _ConnectHint extends StatelessWidget {
  const _ConnectHint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Connect your Google account to check ungraded Classroom work.",
        ),
      ),
    );
  }
}

class _ErrorHint extends StatelessWidget {
  const _ErrorHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isSignedIn,
    required this.isLoading,
    required this.canExport,
    required this.onSignIn,
    required this.onCheckNow,
    required this.onExportCsv,
    required this.onSettings,
  });

  final bool isSignedIn;
  final bool isLoading;
  final bool canExport;
  final VoidCallback onSignIn;
  final VoidCallback onCheckNow;
  final VoidCallback onExportCsv;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: isSignedIn || isLoading ? null : onSignIn,
          icon: Icon(
            isSignedIn ? Icons.check_circle_outline : Icons.login_outlined,
          ),
          label: Text(isSignedIn ? "Signed in" : "Sign in with Google"),
        ),
        FilledButton.tonalIcon(
          onPressed: isLoading ? null : onCheckNow,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: const Text("Check Now"),
        ),
        FilledButton.tonalIcon(
          onPressed: canExport ? onExportCsv : null,
          icon: const Icon(Icons.download_outlined),
          label: const Text("Export CSV"),
        ),
        OutlinedButton.icon(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
          label: const Text("Settings"),
        ),
      ],
    );
  }
}
