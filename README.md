# datadog-prescript

This is a Heroku buildpack to add `datadog/prerunscript.sh` in your dyno, and it will add extra tags in the agent.

## Required Config Var

- `DD_AL_PROCMAP`: JSON of `{ key: [val0, val1], …}`
	- `key` should be the dyno type.
	- `val0` will be used as `al_proc_type`
	- `val1` will be used as `al_proc_subtype`

Note: Buildpack is order-sensitive, but this buildpack does not care where it stands because the important execution timing is when `/app/.profile.d/datadog.sh` runs, in other words: the boot time.

