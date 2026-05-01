# Pointify Milestones

## Milestone 1: Core Platform (CURRENT)
**Goal:** App running on Web + iOS + Android with Auth

### Tasks
- [x] GitHub repo setup
- [x] Supabase project + schema
- [x] Netlify deployment
- [x] Web app (Next.js) - basic landing
- [x] Web Auth (login/signup) ✅
- [x] iOS - Supabase SDK integrated (needs pod install + testing)
- [ ] Android - needs source code or rebuild

### Next Steps
1. Run `pod install` in go-ios/ on Mac
2. Test iOS app with Supabase
3. Decide Android approach (rebuild vs find source)

### Blockers
- Android: Only APK available, no source code

---

## Milestone 2: Features & Polish
**Goal:** Full feature parity with original app + improvements

### Planned
- [ ] Create/edit/delete points
- [ ] Create/edit/delete posts
- [ ] Create/edit/delete events
- [ ] Map view with nearby points
- [ ] User profiles
- [ ] Follow system
- [ ] Push notifications
- [ ] Image uploads (Supabase Storage)
- [ ] Deep linking (Branch.io replacement)

---

## Milestone 3: Launch
**Goal:** Production-ready release

### Planned
- [ ] App Store submission (iOS)
- [ ] Play Store submission (Android)
- [ ] Custom domain for web
- [ ] Analytics
- [ ] Error tracking

---

## Architecture

```
Web (Next.js)  ─┐
iOS (Swift)    ─┼──► Supabase (PostgreSQL + Auth + Storage)
Android (TBD)  ─┘
```

## URLs
- Web: https://pointify-app-114.netlify.app
- GitHub: https://github.com/archanode/Pointify
- Supabase: https://supabase.com/dashboard/project/fjzfreqtmsucbadnhxkc
