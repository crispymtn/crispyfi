# Sets The Raspberry's output volume using "amixer sset PCM,0 <num>%"
# Effective range is from 80 upwards, so this maps 0 to 0 and a 1-10 range to 80-100 respectively.
# Also allows to set the volume to 11 and 9000 (and everything else above 10, for that matter).
class VolumeHandler
  constructor: (initial_step = 5) ->
    @exec = require('child_process').exec
    @set initial_step

  # Changes the output Volume.
  # This requires a command-line call, so we pre-process the argument accordingly.
  # Takes numbers from 0 to 10 (inclusive).
  set: (step) ->
    step = @validate_step step
    vol = @step_to_volume step
    @exec('amixer sset PCM,0 ' + vol + '%', (error, stdout, stderr) -> )
    @current_step = step
    # console.info "Set current volume to #{vol}% / Step #{@current_step}"

  up: () ->
    @set @current_step+1

  down: () ->
    @set @current_step-1

  # Makes sure the step is a number between 0 and 10
  validate_step: (step) ->
    # Sanity check. There is probably a much more elegant way to do this, tips are welcome.
    step = parseInt step
    if isNaN(step)
      step = 0

    return 0 if step <= 0
    return 10 if step >= 10
    return step

  # Maps a given step to an actual volume percentage
  step_to_volume: (step) ->
    return 100 if step >= 10
    return 0 if step <= 0
    return 80 + (2 * step)

# export things
module.exports = (initial_volume = 5) ->
  return new VolumeHandler(initial_volume)
