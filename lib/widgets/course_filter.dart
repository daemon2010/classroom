import "package:flutter/material.dart";

import "../l10n/app_localizations.dart";
import "../models/classroom_models.dart";

class CourseFilter extends StatelessWidget {
  const CourseFilter({
    required this.courses,
    required this.selectedCourseId,
    required this.onlyTurnedIn,
    required this.searchQuery,
    required this.availableSubmittedYears,
    required this.selectedSubmittedYears,
    required this.onCourseChanged,
    required this.onOnlyTurnedInChanged,
    required this.onSearchChanged,
    required this.onSubmittedYearsChanged,
    super.key,
  });

  final List<ClassroomCourse> courses;
  final String? selectedCourseId;
  final bool onlyTurnedIn;
  final String searchQuery;
  final List<int> availableSubmittedYears;
  final Set<int> selectedSubmittedYears;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<bool> onOnlyTurnedInChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<int>> onSubmittedYearsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        final classWidth = isNarrow ? constraints.maxWidth : 260.0;
        final searchWidth = isNarrow ? constraints.maxWidth : 390.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: classWidth,
              child: DropdownButtonFormField<String?>(
                initialValue: selectedCourseId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "",
                  border: OutlineInputBorder(),
                  isDense: true,
                ).copyWith(labelText: l10n.classLabel),
                selectedItemBuilder: (context) {
                  return [
                    Text(
                      l10n.allClasses,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    for (final course in courses)
                      Text(
                        _courseLabel(course),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ];
                },
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: _AllClassesLabel(),
                  ),
                  for (final course in courses)
                    DropdownMenuItem<String?>(
                      value: course.id,
                      child: Text(
                        _courseLabel(course),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: courses.isEmpty ? null : onCourseChanged,
              ),
            ),
            SizedBox(
              width: searchWidth,
              child: TextFormField(
                initialValue: searchQuery,
                decoration: const InputDecoration(
                  labelText: "",
                  hintText: "",
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                ).copyWith(labelText: l10n.search, hintText: l10n.searchHint),
                onChanged: onSearchChanged,
              ),
            ),
            _YearSelectorButton(
              availableYears: availableSubmittedYears,
              selectedYears: selectedSubmittedYears,
              onChanged: onSubmittedYearsChanged,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: FilterChip(
                selected: onlyTurnedIn,
                onSelected: onOnlyTurnedInChanged,
                avatar: Icon(
                  onlyTurnedIn
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                label: Text(l10n.onlyTurnedInTitle),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _courseLabel(ClassroomCourse course) {
    final section = course.section;
    if (section == null || section.isEmpty) {
      return course.name;
    }
    return "${course.name} - $section";
  }
}

class _YearSelectorButton extends StatelessWidget {
  const _YearSelectorButton({
    required this.availableYears,
    required this.selectedYears,
    required this.onChanged,
  });

  final List<int> availableYears;
  final Set<int> selectedYears;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton.icon(
      onPressed: () => _openYearDialog(context),
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text(_buttonLabel(l10n)),
    );
  }

  Future<void> _openYearDialog(BuildContext context) async {
    final l10n = context.l10n;
    var draftYears = selectedYears.isEmpty
        ? {DateTime.now().year}
        : {...selectedYears};

    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.submittedYears),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final year in availableYears)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(year.toString()),
                        value: draftYears.contains(year),
                        onChanged: (checked) {
                          setDialogState(() {
                            final next = {...draftYears};
                            if (checked ?? false) {
                              next.add(year);
                            } else if (next.length > 1) {
                              next.remove(year);
                            }
                            draftYears = next;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final currentYear = DateTime.now().year;
                    Navigator.of(context).pop({currentYear});
                  },
                  child: Text(l10n.currentYear),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(availableYears.toSet());
                  },
                  child: Text(l10n.allYears),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(draftYears),
                  child: Text(l10n.apply),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      onChanged(selected);
    }
  }

  String _buttonLabel(AppLocalizations l10n) {
    final currentYear = DateTime.now().year;
    if (selectedYears.length == availableYears.length &&
        availableYears.every(selectedYears.contains)) {
      return l10n.yearsAll;
    }

    if (selectedYears.length == 1 && selectedYears.contains(currentYear)) {
      return l10n.yearLabel(currentYear);
    }

    final sortedYears = selectedYears.toList()..sort((a, b) => b.compareTo(a));
    return l10n.yearsList(sortedYears.join(", "));
  }
}

class _AllClassesLabel extends StatelessWidget {
  const _AllClassesLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.allClasses,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
