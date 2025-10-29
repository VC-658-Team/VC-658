# VC-658
Fatigue Risk Management System - iOS App for Motorola Solutions Capstone Project

Release Notes (Implementation timeline)
- 1 Created Fatigue Calculator that stores metric and provides calculated score
- 2 Diagrams of the System placed in accompaniment
- 3 Code infrastructure implemented in a Protocol structure
- 4 Removed minimum and maximum values on components as it is no longer needed
- 5 Fixed weightedScore and nomarlisedValue to not take baseline as a parameter against release point (1)
- 6 Protocol fix when calculating to provide correct information when calculating fatigue against point (3)
- 7 Begin adding metrics and calculator protocols against point (3)
- 8 Resting Heart and Sleep metrics complete against point (7)
- 9 Implemented Health app read data authorisation on launch
- 10 Steps and Calories metrics complete against point (7)
---
This makes the first set of implementation (The Fatigue Calculator is functional and the metrics all retrieve data) displayable on a simulator
---

- 11 Implementation of unit test cases
- 12 Implementation of observers to start getting updates on metric data on the watch regularly
- 13 FIX: Check for score threshold
- 14 FIX: Notification doesn't trigger and haptic on open
- 15 FIX: Updated metric to allow a new range to fix Step and calorie bug
- 16 FIX: Notification trigger in the background over a fatigue score of 80
