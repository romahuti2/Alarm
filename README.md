# Alarm

### Mistake

Proper git commit history is missing. I forgot about that, cause went completely in this tricky task. Decided not to fake 'perfect commits', so pushed all at once. 
Development time 3 days.

### Notes

During implementation I intentionaly used different ways of passing data, to show all available and known options:
- delegation
- bind Observable
- closures
- passing viewModel

### Possible future improvements

- Proper MVVM input-output, to avoid use `bindAndFire`
- Better decouple and moving out dependencies (eg. `AudioRecorder recording` files, `NotificationScheduler` notification parameters, share session with player in `AudioManager` etc)
- Add Bindable, some transformations
- Error handling (eg. no permissions)
- Add states to Audio player, recorder.
- Resume approach to modify
- Localization

