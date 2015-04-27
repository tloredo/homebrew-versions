# Homebrew-versions

These formulae provide multiple versions of existing packages, or  newer versions of packages that are too incompatible to go in Homebrew/homebrew yet *(Such as GnuPG21)*.

## How do I install these formulae?

Just `brew tap homebrew/versions` and then `brew install <formula>`.

If the formula conflicts with one from Homebrew/homebrew or another tap, you can `brew install homebrew/versions/<formula>`.

You can also install via URL:

```
brew install https://raw.githubusercontent.com/Homebrew/homebrew-versions/master/<formula>.rb
```

## Acceptable Formulae.

You can read Homebrew’s Acceptable Formulae document [here](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Acceptable-Formulae.md). There are some differences between Homebrew/homebrew and here:

* Versions formulae *cannot* have head or devel sections.
* Versions formulae *can* depend on other versions formulae.
* Please remove any existing bottle block in your formula prior to submission.
* If copied from Homebrew/homebrew prior formulae please remove any deprecated options and fix any issues raised by `brew audit —strict`.

## Troubleshooting
First, please run `brew update` and `brew doctor`.

Second, read the [Troubleshooting Checklist](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Troubleshooting.md#troubleshooting).

**If you don’t read these it will take us far longer to help you with your problem.**

## More Documentation

`brew help`, `man brew` or check [our documentation](https://github.com/Homebrew/homebrew/tree/master/share/doc/homebrew#readme).

## License
Code is under the [BSD 2 Clause (NetBSD) license](https://github.com/Homebrew/homebrew/tree/master/LICENSE.txt).