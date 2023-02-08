[![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx) 
[![License](https://img.shields.io/badge/License-Apache%202.0-grey.svg)](LICENSE.md) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-grey.svg)](CODE_OF_CONDUCT.md)

Use [Nyx](https://github.com/mooltiverse/nyx) from within GitHub Actions.

[Nyx](https://github.com/mooltiverse/nyx) is a powerful, flexible and extremely configurable semantic release tool. You can put release management on auto pilot regardless of the kind of project, languages, tools and technologies or you can control any aspect of release management manually.

This is a companion project to Nyx, providing just the GitHub Action. For a reference on Nyx, its capabilities and configuration please jump to the **[documentation](https://mooltiverse.github.io/nyx/)**.

## Usage

TODO: write this section

### Git repository checkout action

Your pipelines on GitHub Actions probably start with the checkout action, which, by default, only checks out the latest commit as the fetch-depth parameter defaults to 1.

This prevents Nyx from inferring information from the commit history and you likely end up with the inferred version to always be the initial version (i.e. 0.1.0) as further illustrated here.

To work around this you just have to configure the checkout action to always fetch the entire commit history by setting the fetch-depth parameter to 0 as documented here:

```yaml
- uses: actions/checkout@v3
  with:
    fetch-depth: 0
```

### Combined release process

Just like for other means of using Nyx, in order to [separate Nyx actions and run other jobs or steps in between](https://mooltiverse.github.io/nyx/guide/user/introduction/combined-release-process/), you can run this action multiple times passing different commands (see the `command` parameter). Just make sure you enable the state file (using the `stateFile` parameter) and the resume flag (using the `resume` parameter).

In case you run Nyx in separate jobs (instead of just separate steps within the same job), you may also wish to bring the state file ahead along with the pipeline progress so you can use the [cache action](https://github.com/actions/cache), like in this example:

```yaml
jobs:
  my job:
    name: Do something
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Set up the cache to store the Nyx state
      uses: actions/cache@v3
      with:
        path: |
          .nyx-state.json
        key: ${{ github.run_id }}-${{ github.job }}-nyx-state
        restore-keys: ${{ github.run_id }}-${{ github.job }}-nyx-state
    - name: Run nyx
      uses: actions/nyx-github-action@main
      with:
        command: infer
        resume: true
        stateFile: .nyx-state.json
```

## Examples

TODO: write this section

## Inputs

When using the GitHub Action, Nyx can be configured by using one or more [configuration files](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/) (using JSON or YAML grammars, putting them in their default paths or using custom ones) or passing inputs to the Action itself. Configuration files give you the complete range of options so thet are the suggested way if you need to fine tune the settings.

Action inputs are a subset of [all the available configuration options](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/) and this is due to Actions not supporting options with dynamic names. Nonetheless they give you a handy way to set the most common settings.

For a full reference on the configuration see the [Nyx configuration reference](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/) while this is the list of options available to this Action:

| Name                                                      | Notes |
| --------------------------------------------------------- | ----- |
| `command` | Selects which [Nyx command](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/) to run. Allowed values are: `clean`, `infer` (default), `make`, `mark`, `publish`. When selecting `infer` Nyx will only read the repository and give you back the inferred `version`. `make` will build the changelog, `mark` will apply tags, make commits and push changes to the remote repository. `publish` will publish the release to the configured services |
| [`bump`]([#bump](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#bump)) | Instructs Nyx on which identifier to bump on the past version in order to build the new `version`. This option prevents Nyx to [infer](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer) the identifier to bump from the commit history. |
| [`changelogPath`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/changelog/#path) | The absolute or relative path to a local file where the changelog is saved when generated. If a file already exists at the given location it is overwritten. Setting this value also enables the changelog creation, which is to say, when this option is not defined no changelog is generated. A common value used for this option is `CHANGELOG.md` |
| [`changelogTemplate`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/changelog/#template) | The absolute or relative path to a local file to use as a template instead of the Nyx built-in. The file must contain a valid [Handlebars](https://handlebarsjs.com/) template ([Mustache](https://mustache.github.io/) templates are also supported). Template [functions](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/templates/#functions) can be used in custom templates |
| [`commitMessageConventionsEnabled`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/commit-message-conventions/#enabled) | The comma separated list of commit message convention names that are enabled for the project. Here you can enable or disable the various conventions, either custom or default. The list of [available conventions](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/commit-message-conventions/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`configurationFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#configuration-file) | This option allows you to load a configuration file from a location other than default ones. This can be a relative (to the Action's working directory) path to a local file or an URL to load a remote file. This configuration file can override other options, as per the [evaluation order](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order), and can be authored as `.yaml` (or `.yml`) or `.json` (the format is inferred by the file extension or JSON is used by default) just like the default configuration files |
| [`directory`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#directory) | Sets the working directory for Nyx. The directory is where Nyx searches for the Git repository and is also used as the base path when relative paths to local files or directories. By default Nyx uses the Action's working directory for this. Paths defined here must be relative to the Action's working directory |
| [`dryRun`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#dry-run) | When this flag is set to `true` no action altering the repository state, either local or remote, is taken. Instead the actions that would be taken if this flag was not set are printed to the log |
| [`initialVersion`]([#initial-version](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#initial-version)) | The default version to use when no previous version can be [inferred](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer) from the commit history (i.e. when the repository has no tagged releases yet) |
| [`preset`]([#preset](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#preset)) | This option allows you to import one [preset configuration](https://mooltiverse.github.io/nyx/guide/user/configuration-presets/) into your configuration to save configuration time and effort |
| [`releaseLenient`]([#release-lenient](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#release-lenient)) | When this option is enabled (it is by default), Nyx will attempt to tolerate prefixes and other unnecessary characters (like leading zeroes) when **reading** Git tags from the commit history. When `true`, tags like `vx.y.x`, `relx.y.x` etc will be detected as release tags (for version `x.y.x`), regardless of the prefix Nyx uses to generate release names |
| [`releasePrefix`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#release-prefix) | It’s a common practice to add a leading string to version numbers to give releases a name. Common prefixes are v or rel but you might use anything, or no prefix at all |
| [`releaseTypesEnabled`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#enabled) | The comma separated list of release types that are enabled for the project. Here you can enable or disable the various release types, either custom or default. The list of [available release types](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`releaseTypesPublicationServices`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publication-services) | The comma separated list of service configuration names to be used to publish releases when the matched release type has the [`publish`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publish) flag enabled. The list of [available services](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/services/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`releaseTypesRemoteRepositories`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#remote-repositories) | The comma separated list of remote repository names to be used to push changes to when the matched release type has the [`gitPush`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#git-push) flag enabled. The list of [available remote repositories](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/git/#remotes) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`resume`]([#resume](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#resume)) | When this flag is set to `true` Nyx tries to load an existing [state file](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) and resume operations from where it left when the state file was saved |
| [`scheme`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#scheme) | Selects the [version scheme](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/) to use. Defaults to [SEMVER](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/#semantic-versioning-semver) |
| [`sharedConfigurationFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#shared-configuration-file) | This option allows you to load a shared configuration file from a location other than [default ones](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`stateFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) | Enables the creation of the [state file](https://mooltiverse.github.io/nyx/guide/user/state-reference/) where Nyx stores its findings and generated values |
| [`summaryFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#summary-file) | Enables the creation of the summary file where Nyx saves a subset of relevant information from the internal state as name value pairs, easy to parse |
| [`verbosity`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#verbosity) | Controls the amount of output emitted by Nyx, where values are: `FATAL`, `ERROR`, `WARNING`, `INFO`, `DEBUG`, `TRACE` |
| [`version`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#version) | Overrides the version and prevents Nyx to [infer](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer). When overriding this value you take over the tool and go the manual versioning way so Nyx won’t try to read past versions from the commit history nor determine which identifiers to bump |

TODO: write this section

## Outputs

The following are the outputs from the action:

| Name                                                      | Notes |
| --------------------------------------------------------- | ----- |
| `branch` | This string contains the current Git branch name |
| `bump` | This string contains the name of the identifier that has been bumped to create the new `version`. Version identifiers depend on the selected version `scheme` |
| `coreVersion` | This value is `true` when the `version` only uses *core* identifiers (i.e. is not a pre-release) according to the `scheme` |
| `latestVersion` | This value is `true` when the `version` is the latest in the repository, meaning that, according to the `scheme`, there are no other tags in the Git repository representing any version greater than `version` |
| `newRelease` | This value is `true` when the `newVersion` is `true` and a new release with the current `version` has to be [issued](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publish) |
| `newVersion` | This value is `true` when the `version` is new and is basically a shorthand to testing if `version` is different than the `previousVersion` |
| `scheme` | The configured [version `scheme`](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/) |
| `timestamp` | The timestamp in the Unix format (seconds since Jan 01 1970. (UTC). Example: `1591802533` |
| `previousVersion` | The version that was released before the one being created |
| `primeVersion` | The version that is used as the baseline when bumping version numbers when the release type uses [collapsed versioning](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#collapse-versions) (the *pre-release* versioning) |
| `version` | The version that was [inferred](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer), unless the [`version`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#version) configuration option was passed to override inference. When the version is not overridden or inferred the [`initialVersion`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#initial-version) is used |

All the above outputs are also contained in the [state file](https://mooltiverse.github.io/nyx/guide/user/state-reference/) (if enabled using the [`stateFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) option) or the summary file (if enabled using the [`summaryFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#summary-file) option).

## Limitations

This is a [Docker Action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) so it's only available for Linux runners.

## Support

TODO: write this section

## Badge

If you like Nyx please consider showing the badge [![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx) on your project page by inserting this snippet:

```md
[![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx)
```
