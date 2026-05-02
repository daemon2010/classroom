import "package:flutter/material.dart";

import "../l10n/app_localizations.dart";
import "../models/classroom_models.dart";

class CourseFilter extends StatelessWidget {
  const CourseFilter({
    required this.courses,
    required this.selectedCourseId,
    required this.searchQuery,
    required this.onCourseChanged,
    required this.onSearchChanged,
    super.key,
  });

  final List<ClassroomCourse> courses;
  final String? selectedCourseId;
  final String searchQuery;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String> onSearchChanged;

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
