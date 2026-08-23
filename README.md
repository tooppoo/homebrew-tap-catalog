# homebrew-tap-catalog

## packages

- [`git-kura`](https://github.com/tooppoo/git-kura): installs `git-kura`, a keyed Git worktree resolver.
- [`enozunu`](https://github.com/tooppoo/enozunu): installs `enozunu`, a cross-provider configuration materializer for AI agent tooling.
- [`reportage`](https://github.com/tooppoo/reportage): installs `reportage`, an explicit, runtime-agnostic, coverage-aware E2E scenario runner.

## Usage

```sh
brew install tooppoo/tap-catalog/git-kura
brew install tooppoo/tap-catalog/enozunu
brew install tooppoo/tap-catalog/reportage
```

### Installing a past version

A version bump moves the release it replaces into a versioned formula, named after its `major.minor` line:

```sh
brew install tooppoo/tap-catalog/<package>@<major>.<minor>
```

A line only exists once a version bump has superseded a release on it, so a package that has not been bumped since this tooling landed has none.
The lines available for a package are the `Formula/<package>@<major>.<minor>.rb` files in [Formula](Formula).

One formula is kept per line, holding the newest release of that line that is no longer current.
While a line is still the current one its formula advances with each further release on that line; the bump that moves the package to a newer line leaves it holding that line's last release, and it never changes again.
So `brew upgrade` moves an installed versioned formula along with its line; use `brew pin` to hold an exact version.

A versioned formula is keg-only, so installing it alongside the current release does not take over the command.
Either direction is a single `brew link`, with no `brew unlink` first:

```sh
brew link <package>@<major>.<minor>   # switch to the archived line
brew link <package>                   # switch back to the current release
```

Uninstalling a versioned formula does not relink the current release, so run `brew link` for it afterwards.
Installed on its own, a versioned formula is linked like any other and needs no extra step.
