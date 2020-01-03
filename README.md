# datadog-prescript

This is a Heroku buildpack to add `datadog/prerunscript.sh` in your dyno, and it will add extra tags in the agent.

## Extra tags this buildpack will add are;

- `al_service`
- `al_proc_type`
- `al_proc_subtype`

## Source and precedence of values

### `al_service`

This is obvious and same among the dynos/pods.

1. `$AL_SERVICE`
2. `$DD_AL_SERVICE`
3. `"unknown"`

### `al_proc_type`

`web` and `worker`, depends on each dyno/pod.

1. `$AL_PROC_TYPE`
2. `$DD_AL_PROCMAP[$DYNO_TYPE][0]`
3. `$DD_AL_PROC_TYPE`
4. `$DYNO_TYPE`
5. `"unknown"`

### `al_proc_subtype`

The name of program that runs on each dyno/pod.

1. `$AL_PROC_SUBTYPE`
2. `$DD_AL_PROCMAP[$DYNO_TYPE][1]`
3. `$DD_AL_PROC_SUBTYPE`
4. `"unknown"`

## `$DD_AL_PROCMAP`

`$DD_AL_PROCMAP` is JSON of `{ key: [val0, val1], …}`

- `key` should be the dyno type.
- `val0` will be used as `al_proc_type`
- `val1` will be used as `al_proc_subtype`

Note: Buildpack is order-sensitive, but this buildpack does not care where it stands because the important execution timing is when `/app/.profile.d/datadog.sh` runs, in other words: the boot time.
