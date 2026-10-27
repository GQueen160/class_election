# Ijwi · Class Election

**Project chosen:** Class Election (Mobile Programming · Week 2 · Mini Project Building)

The class elects its representative. Names are cleaned, every voter votes exactly once,
results are ranked, and a tie never becomes a fake winner.

## Features
- Three sample candidates to start
- Names cleaned before use (trim, single spaces, Title Case) for voters and candidates
- One vote per voter (`aLINE` and `Aline` are the same voter)
- Results: votes, percentage (one decimal), bar, ranked highest first
- Winner / tie banner, and "No votes yet" before any vote (never NaN%)
- Add a candidate (not empty, not a duplicate); remove one with no votes, with Undo
- Reset all votes after an "Are you sure?" dialog

## Session 5 · Part 2: saving + an API
- **Saved on the phone (shared_preferences):** the candidates, every vote and who already voted.
  A voter who voted yesterday still cannot vote again today.
- `Candidate` and `Election` have `toJson` / `fromJson` (`loadFromJson`); `lib/storage.dart` has
  `saveElection` and `loadElection`.
- The app loads the saved election once when it opens (spinner meanwhile); the first time it shows the
  three sample candidates.
- Saved after every change: vote, add candidate, delete candidate, Undo, reset.
- **Live API:** the Vote screen shows election-day weather in Kigali (Open-Meteo) with the three states:
  loading (spinner), error (message + Retry), data.

## Run it
```
flutter create .      # once, to generate the android/ios/web folders
flutter pub get
flutter run
flutter test          # runs the checks from the "done when" list
```

## Screenshots
<!-- Add at least four: Vote, Results (with a winner), Results (with a tie), Candidates, Reset dialog -->

## Think questions

**1. Why must names be cleaned before they are compared? Give an example of what goes wrong otherwise.**

_Write your answer here, in your own words._

**2. How does your app decide between a winner and a tie? Explain it in plain words.**

_Write your answer here, in your own words._
