# ProItheus' personal tap

This cask is mostly ready for public usage, and I'll maintain at best effort. Happy to accept PR.

Casks for macOS apps that cannot be included in the official
[homebrew/cask](https://github.com/Homebrew/homebrew-cask) tap — primarily
because they are **not notarized by Apple**. Homebrew requires submitted casks
to pass Gatekeeper on supported macOS versions, which means developers must
sign and notarize their apps (and provide personal info and pay to apple). See Homebrew's
[Acceptable Casks](https://docs.brew.sh/Acceptable-Casks#rejected-casks)
policy for details.

All casks in this tap automatically **strip the macOS quarantine attribute**
from installed `.app` bundles via a `postflight` block. This bypasses
Gatekeeper verification so the app can launch. **This poses a security risk**
— only install these casks if you trust this tap's maintainer or have
personally reviewed the cask source.


## Install

```bash
brew tap proitheus/mytap
brew install --cask <cask>
```

Or directly:

```bash
brew install proitheus/mytap/<cask>
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
