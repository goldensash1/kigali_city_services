# Submission Checklist

## 1) Reflection PDF
- [ ] Convert `docs/implementation_reflection.md` to PDF
- [ ] Include at least 2 Firebase errors with screenshots + fixes

## 2) GitHub Repository
- [ ] Push full source code to GitHub
- [ ] Ensure at least 10 meaningful commits
- [ ] Confirm README explains setup, architecture, Firestore schema

## 3) Demo Video (7–12 min)
- [ ] Auth flow shown (signup, login, logout, verification)
- [ ] Create/Edit/Delete listing shown
- [ ] Search + filter shown
- [ ] Detail + embedded map + navigation shown
- [ ] Firebase Console visible during actions

## 4) Design Summary PDF (1–2 pages)
- [ ] Convert `docs/design_summary.md` to PDF
- [ ] Explain schema, state flow, trade-offs

## 5) Technical Verification
- [ ] `flutter analyze` passes
- [ ] App runs on emulator/physical device (not browser-only)
- [ ] Firebase keys/config are not committed if private

## Export Tip
Use VS Code Markdown preview + Print to PDF, or use:

```bash
pandoc docs/implementation_reflection.md -o Implementation_Reflection.pdf
pandoc docs/design_summary.md -o Design_Summary.pdf
```
