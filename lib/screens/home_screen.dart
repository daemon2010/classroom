import "dart:async";

import "package:flutter/material.dart";

import "../app.dart";
import "../l10n/app_localizations.dart";
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
  ReportSortColumn _sortColumn = ReportSortColumn.submitted;
  bool _sortAscending = false;
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.services.reportController;
    final settings = widget.services.settings.settings;
    _selectedCourseId = settings.lastSelectedCourseId;
    _controller.addListener(_handleControllerChanged);
    widget.services.settings.addListener(_handleSettingsChanged);
    _startClock();
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
    _clockTimer?.cancel();
    _controller.removeListener(_handleControllerChanged);
    widget.services.settings.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _sortedRows(_filteredRows(_controller.snapshot.rows));
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
              currentTime: _currentTime,
              ungradedCount: filteredRows.length,
            ),
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
              searchQuery: _searchQuery,
              onCourseChanged: (courseId) {
                setState(() {
                  _selectedCourseId = courseId;
                });
                unawaited(
                  widget.services.settings.setLastSelectedCourseId(courseId),
                );
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
                sortColumn: _sortColumn,
                sortAscending: _sortAscending,
                onSort: _handleSortChanged,
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
      if (!settings.rememberLastSelectedCourse) {
        _selectedCourseId = null;
      } else {
        _selectedCourseId = _validCourseSelection(_controller.courses);
      }
    });
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _connect() async {
    final connected = await _controller.signIn();
    if (!mounted || connected) {
      return;
    }

    _showMessage(_controller.lastError ?? context.l10n.googleSignInFailed);
  }

  Future<void> _refreshReport() async {
    final refreshed = await _controller.refreshReport();
    if (!mounted || refreshed) {
      return;
    }

    _showMessage(_controller.lastError ?? context.l10n.classroomCheckFailed);
  }

  List<UngradedSubmissionReportRow> _filteredRows(
    List<UngradedSubmissionReportRow> rows,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final settings = widget.services.settings.settings;
    final currentYear = DateTime.now().year;

    return rows
        .where((row) {
          if (_selectedCourseId != null && row.courseId != _selectedCourseId) {
            return false;
          }

          if (!settings.displayAllYears) {
            final submittedYear = _submittedDate(row)?.toLocal().year;
            if (submittedYear != currentYear) {
              return false;
            }
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

  List<UngradedSubmissionReportRow> _sortedRows(
    List<UngradedSubmissionReportRow> rows,
  ) {
    final sorted = rows.toList(growable: false);
    sorted.sort((a, b) => _compareRows(a, b));
    return sorted;
  }

  int _compareRows(
    UngradedSubmissionReportRow a,
    UngradedSubmissionReportRow b,
  ) {
    final result = switch (_sortColumn) {
      ReportSortColumn.student => _compareText(
        a.studentName,
        b.studentName,
        ascending: _sortAscending,
      ),
      ReportSortColumn.email => _compareText(
        a.studentEmail,
        b.studentEmail,
        ascending: _sortAscending,
      ),
      ReportSortColumn.course => _compareText(
        a.courseName,
        b.courseName,
        ascending: _sortAscending,
      ),
      ReportSortColumn.subject => _compareText(
        a.subject,
        b.subject,
        ascending: _sortAscending,
      ),
      ReportSortColumn.assignment => _compareText(
        a.assignmentTitle,
        b.assignmentTitle,
        ascending: _sortAscending,
      ),
      ReportSortColumn.state => _compareText(
        _stateLabel(a.submissionState),
        _stateLabel(b.submissionState),
        ascending: _sortAscending,
      ),
      ReportSortColumn.late => _compareBool(
        a.isLate,
        b.isLate,
        ascending: _sortAscending,
      ),
      ReportSortColumn.submitted => _compareDate(
        _submittedDate(a),
        _submittedDate(b),
        ascending: _sortAscending,
      ),
    };

    if (result != 0) {
      return result;
    }

    return _compareDate(_submittedDate(a), _submittedDate(b), ascending: false);
  }

  int _compareText(String? a, String? b, {required bool ascending}) {
    final cleanA = a?.trim().toLowerCase();
    final cleanB = b?.trim().toLowerCase();
    final aEmpty = cleanA == null || cleanA.isEmpty;
    final bEmpty = cleanB == null || cleanB.isEmpty;
    if (aEmpty && bEmpty) {
      return 0;
    }
    if (aEmpty) {
      return 1;
    }
    if (bEmpty) {
      return -1;
    }
    final result = cleanA.compareTo(cleanB);
    return ascending ? result : -result;
  }

  int _compareBool(bool a, bool b, {required bool ascending}) {
    if (a == b) {
      return 0;
    }
    final result = a ? 1 : -1;
    return ascending ? result : -result;
  }

  int _compareDate(DateTime? a, DateTime? b, {required bool ascending}) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

  DateTime? _submittedDate(UngradedSubmissionReportRow row) {
    return row.submittedAt ?? row.updatedAt;
  }

  void _handleSortChanged(ReportSortColumn column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _sortAscending = ascending;
    });
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
      rows: _sortedRows(_filteredRows(_controller.snapshot.rows)),
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

    _showMessage(context.l10n.csvExported);
  }

  void _openSettings() {
    Navigator.of(context).pushNamed("/settings");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _stateLabel(SubmissionState state) {
    return switch (state) {
      SubmissionState.newSubmission => context.l10n.newState,
      SubmissionState.created => context.l10n.assignedState,
      SubmissionState.turnedIn => context.l10n.turnedInState,
      SubmissionState.returned => context.l10n.returnedState,
      SubmissionState.reclaimedByStudent => context.l10n.takenBackState,
      SubmissionState.unknown => context.l10n.unknown,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton(
          tooltip: l10n.settings,
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
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
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Tooltip(
              message: isSignedIn ? l10n.signedIn : l10n.signInWithGoogle,
              child: FilledButton.icon(
                onPressed: isSignedIn || isLoading ? null : onSignIn,
                icon: Icon(
                  isSignedIn
                      ? Icons.check_circle_outline
                      : Icons.login_outlined,
                ),
                label: Text(
                  isSignedIn
                      ? (compact ? l10n.signed : l10n.signedIn)
                      : (compact ? l10n.signIn : l10n.signInWithGoogle),
                ),
              ),
            ),
            Tooltip(
              message: l10n.checkNow,
              child: FilledButton.tonalIcon(
                onPressed: isLoading ? null : onCheckNow,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(compact ? l10n.check : l10n.checkNow),
              ),
            ),
            Tooltip(
              message: l10n.exportCsv,
              child: FilledButton.tonalIcon(
                onPressed: canExport ? onExportCsv : null,
                icon: const Icon(Icons.download_outlined),
                label: Text(compact ? l10n.export : l10n.exportCsv),
              ),
            ),
            Tooltip(
              message: l10n.settings,
              child: OutlinedButton.icon(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined),
                label: Text(l10n.settings),
              ),
            ),
          ],
        );
      },
    );
  }
}
