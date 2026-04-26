import "package:flutter/material.dart";

import "../app.dart";
import "../models/classroom_models.dart";
import "../services/google_auth_service.dart";
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
  GoogleAuthStatus _authStatus = const GoogleAuthStatus.signedOut();
  ReportSnapshot _snapshot = ReportSnapshot.empty();
  List<ClassroomCourse> _courses = const [];
  String? _selectedCourseId;
  String _searchQuery = "";
  bool _onlyTurnedIn = true;
  bool _loading = false;
  bool _hasLoadedRows = false;
  DateTime? _lastChecked;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _filteredRows();
    final filteredSummary = _summaryFor(filteredRows);
    final isSignedIn = _authStatus.state == GoogleAuthState.signedIn;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onSettings: _openSettings),
            const SizedBox(height: 14),
            StatusPanel(
              authStatus: _authStatus,
              lastChecked: _lastChecked,
              ungradedCount: filteredRows.length,
            ),
            if (!isSignedIn) ...[
              const SizedBox(height: 10),
              const _ConnectHint(),
            ],
            const SizedBox(height: 12),
            _ActionBar(
              isSignedIn: isSignedIn,
              isLoading: _loading,
              canExport: _hasLoadedRows,
              onSignIn: _connect,
              onCheckNow: _refreshReport,
              onExportCsv: _exportCsv,
              onSettings: _openSettings,
            ),
            const SizedBox(height: 12),
            CourseFilter(
              courses: _courses,
              selectedCourseId: _selectedCourseId,
              onlyTurnedIn: _onlyTurnedIn,
              searchQuery: _searchQuery,
              onCourseChanged: (courseId) {
                setState(() {
                  _selectedCourseId = courseId;
                });
              },
              onOnlyTurnedInChanged: (value) {
                setState(() {
                  _onlyTurnedIn = value;
                });
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
            Expanded(child: ReportTable(rows: filteredRows)),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStatus() async {
    final status = await widget.services.googleAuth.currentStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _authStatus = status;
    });
  }

  Future<void> _connect() async {
    try {
      await widget.services.googleAuth.signIn();
    } on GoogleAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    await _refreshReport();
  }

  Future<void> _refreshReport() async {
    setState(() {
      _loading = true;
    });

    final authStatus = await widget.services.googleAuth.currentStatus();
    final isSignedIn = authStatus.state == GoogleAuthState.signedIn;

    if (!isSignedIn) {
      if (!mounted) {
        return;
      }

      setState(() {
        _authStatus = authStatus;
        _courses = const [];
        _snapshot = ReportSnapshot.empty();
        _hasLoadedRows = false;
        _loading = false;
      });
      return;
    }

    final myProfile = await widget.services.classroomApi.getMyProfile();
    final courses = await widget.services.classroomApi.listCourses();
    final courseWork = <ClassroomCourseWork>[];
    final submissions = <ClassroomSubmission>[];

    for (final course in courses) {
      final workItems = await widget.services.classroomApi.listCourseWork(
        course.id,
      );
      courseWork.addAll(workItems);

      for (final work in workItems) {
        final workSubmissions = await widget.services.classroomApi
            .listStudentSubmissions(courseId: course.id, courseWorkId: work.id);
        submissions.addAll(workSubmissions);
      }
    }

    final snapshot = widget.services.report.buildSnapshot(
      myProfile: myProfile,
      courses: courses,
      courseWork: courseWork,
      submissions: submissions,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _authStatus = authStatus;
      _courses = courses;
      _snapshot = snapshot;
      _lastChecked = DateTime.now();
      _hasLoadedRows = true;
      _loading = false;
    });
  }

  List<UngradedSubmissionReportRow> _filteredRows() {
    final query = _searchQuery.trim().toLowerCase();

    return _snapshot.rows
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
      courseCount: _courses.length,
      assignmentCount: rows.map((row) => row.courseWorkId).toSet().length,
      ungradedSubmissionCount: rows.length,
      classesWithUngradedCount: rows.map((row) => row.courseId).toSet().length,
      lateSubmissionCount: rows.where((row) => row.isLate).length,
    );
  }

  void _exportCsv() {
    widget.services.csvExport.buildCsv(_filteredRows());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CSV export is not available yet.")),
    );
  }

  void _openSettings() {
    Navigator.of(context).pushNamed("/settings");
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
