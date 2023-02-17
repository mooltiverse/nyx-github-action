[![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx) 
[![License](https://img.shields.io/badge/License-Apache%202.0-grey.svg)](LICENSE.md) [![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-grey.svg)](CODE_OF_CONDUCT.md)

Use [Nyx](https://github.com/mooltiverse/nyx) from within GitHub Actions.

[Nyx](https://github.com/mooltiverse/nyx) is a powerful, flexible and extremely configurable semantic release tool. You can put release management on auto pilot regardless of the kind of project, languages, tools and technologies or you can control any aspect of release management manually.

This is a companion project to Nyx, providing just the GitHub Action. For a reference on Nyx, its capabilities and configuration please jump to the **[documentation](https://mooltiverse.github.io/nyx/)**.

## Usage

In the simples case you just need the Action to compute the version number from the repository commit history. [This example](https://github.com/mooltiverse/nyx-github-action/blob/main/.github/workflows/example-get-version.yml) shows how:

```yaml
jobs:
  infer-version:
    name: Infer the repository version with Nyx
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Nyx infer
      id: nyx
      uses: mooltiverse/nyx-github-action@main
    - name: Print version # This step uses the version inferred by Nyx
      run: echo the inferred version is ${{ steps.nyx.outputs.version }}
```

Very simple, and you can then use the version as `${{ steps.nyx.outputs.version }}`.

If you want Nyx not just to *read* the repository but also publish a release or push changes to a remote repository, you also need to pass the credentials using the `GITHUB_TOKEN` and giving the `mark` or `publish` command (more on commands below), like in [this example](https://github.com/mooltiverse/nyx-github-action/blob/main/.github/workflows/example-publish.yml):

```yaml
jobs:
  infer-version:
    name: Publish the release (if any) with Nyx
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Nyx publish
      id: nyx
      uses: mooltiverse/nyx-github-action@main
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        NYX_VERBOSITY: 'INFO'
      with:
        command: 'publish'
        changelogPath: 'CHANGELOG.md'
        preset: 'extended'
        releaseLenient: 'true'
        stateFile: '.nyx-state.json'
        summaryFile: '.nyx-summary.txt'
```

Here the *verbosity* is passed as an environment variable (`NYX_VERBOSITY`) just like the `GITHUB_TOKEN` secret, while we also use a preset and generate a few other files from Nyx. The `GH_TOKEN` is an arbitrary name and needs to match the one used for the configured [`AUTHENTICATION_TOKEN`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/services/#github-configuration-options). The configuration of services is detailed [here](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/services/) and is out of the scope of this document. However, in order to avoid hardcoding values, secrets can be fetched from environment variables, like in this configuration snippet from a `.nyx.json` file:

```json
"services":{
    "github": {
      "type": "GITHUB",
      "options": {
        "AUTHENTICATION_TOKEN": "{{#environmentVariable}}GH_TOKEN{{/environmentVariable}}",
        "REPOSITORY_NAME": "myrepo",
        "REPOSITORY_OWNER": "acme"
      }
    }
  },
```

### Git repository checkout action

Your pipelines on GitHub Actions probably start with the [checkout action](https://github.com/actions/checkout), which, by default, only checks out the latest commit as the fetch-depth parameter defaults to 1.

This prevents Nyx from inferring information from the commit history and you likely end up with the inferred version to always be the initial version (i.e. 0.1.0) as further illustrated here.

To work around this you just have to configure the checkout action to always fetch the entire commit history by setting the `fetch-depth` parameter to `0` as in this example:

```yaml
- uses: actions/checkout@v3
  with:
    fetch-depth: 0
```

### Combined release process

Just like for other means of using Nyx, in order to [separate Nyx actions and run other jobs or steps in between](https://mooltiverse.github.io/nyx/guide/user/introduction/combined-release-process/), you can run this action multiple times passing different commands (see the `command` parameter). Just make sure you enable the state file (using the `stateFile` parameter) and the resume flag (using the `resume` parameter).

```yaml
jobs:
  job1:
    name: My job
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Run nyx Infer
      uses: mooltiverse/nyx-github-action@main
      with:
        command: infer
        resume: true
        stateFile: .nyx-state.json
    # Run other tasks here....
    - name: Run nyx Publish
      uses: mooltiverse/nyx-github-action@main
      with:
        command: publish
        resume: true
        stateFile: .nyx-state.json
```

In case you run Nyx in separate jobs (instead of just separate steps within the same job), you may also wish to bring the state file ahead along with the pipeline progress so you can use the [cache action](https://github.com/actions/cache), like in this example:

```yaml
jobs:
  job1:
    name: My job 1
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Set up the cache to store and retrieve the Nyx state
      uses: actions/cache@v3
      with:
        path: |
          .nyx-state.json
        key: ${{ github.run_id }}-nyx-state
        restore-keys: ${{ github.run_id }}-nyx-state
    - name: Run nyx Infer
      uses: mooltiverse/nyx-github-action@main
      with:
        command: infer
        resume: true
        stateFile: .nyx-state.json

  job2:
    name: My job 2
    needs: job1
    runs-on: ubuntu-latest
    steps:
    - name: Git checkout
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    - name: Set up the cache to store and retrieve the Nyx state
      uses: actions/cache@v3
      with:
        path: |
          .nyx-state.json
        key: ${{ github.run_id }}-nyx-state
        restore-keys: ${{ github.run_id }}-nyx-state
    - name: Run nyx Publish
      uses: mooltiverse/nyx-github-action@main
      with:
        command: publish
        resume: true
        stateFile: .nyx-state.json
```

Using separate jobs may also come very useful when using [matrix builds](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs).

## Examples

You can find live working examples in [this](https://github.com/mooltiverse/nyx-github-action/tree/main/.github/workflows) folder.

## Reference

### Inputs

Nyx supports a [variety of configuration means](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/), including configuration files, command line arguments and environment variables. All configurable options are accessible via any of the supported configuration methods. The [configuration reference](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/) gives you full details on each option.

Using the GitHub Action you can use:

* [configuration files](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/) (using JSON or YAML grammars, putting them in their default paths or using custom ones)
* [environment variables](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#environment-variables), which is the suggested way for passing [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets), using the [`env`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsenv) block in [workflow files](https://docs.github.com/en/actions/using-workflows/about-workflows) (i.e. passing the `GITHUB_TOKEN`)
* action inputs, using the [`with`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepswith) block in [workflow files](https://docs.github.com/en/actions/using-workflows/about-workflows)

When using the GitHub Action, action inputs replace [command line options](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#command-line-options), which are not available with Actions. Action inputs are a subset of all the available command line arguments and this is due to Actions not supporting options with dynamic names. Nonetheless they give you a handy way to set the most common settings. For all those arguments not available as inputs you can still use configuration files or environment vraiables. Action inputs will be passed to Nyx as [command line arguments](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#command-line-options) under the hood so they have priority over all other configuration means.

This is the list of options available to this Action:

| Name                                                      | Notes |
| --------------------------------------------------------- | ----- |
| `command` | Selects which [Nyx command](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/) to run. Allowed values are: `clean`, `infer` (default), `make`, `mark`, `publish`. When selecting `infer` Nyx will only read the repository and give you back the inferred `version`. `make` will build the changelog, `mark` will apply tags, make commits and push changes to the remote repository. `publish` will publish the release to the configured services |
| [`bump`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#bump) | Instructs Nyx on which identifier to bump on the past version in order to build the new `version`. This option prevents Nyx to [infer](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer) the identifier to bump from the commit history. |
| [`changelogPath`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/changelog/#path) | The absolute or relative path to a local file where the changelog is saved when generated. If a file already exists at the given location it is overwritten. Setting this value also enables the changelog creation, which is to say, when this option is not defined no changelog is generated. A common value used for this option is `CHANGELOG.md` |
| [`changelogTemplate`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/changelog/#template) | The absolute or relative path to a local file to use as a template instead of the Nyx built-in. The file must contain a valid [Handlebars](https://handlebarsjs.com/) template ([Mustache](https://mustache.github.io/) templates are also supported). Template [functions](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/templates/#functions) can be used in custom templates |
| [`commitMessageConventionsEnabled`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/commit-message-conventions/#enabled) | The comma separated list of commit message convention names that are enabled for the project. Here you can enable or disable the various conventions, either custom or default. The list of [available conventions](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/commit-message-conventions/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`configurationFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#configuration-file) | This option allows you to load a configuration file from a location other than default ones. This can be a relative (to the Action's working directory) path to a local file or an URL to load a remote file. This configuration file can override other options, as per the [evaluation order](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order), and can be authored as `.yaml` (or `.yml`) or `.json` (the format is inferred by the file extension or JSON is used by default) just like the default configuration files |
| [`directory`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#directory) | Sets the working directory for Nyx. The directory is where Nyx searches for the Git repository and is also used as the base path when relative paths to local files or directories. By default Nyx uses the Action's working directory for this. Paths defined here must be relative to the Action's working directory |
| [`dryRun`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#dry-run) | When this flag is set to `true` no action altering the repository state, either local or remote, is taken. Instead the actions that would be taken if this flag was not set are printed to the log |
| [`initialVersion`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#initial-version) | The default version to use when no previous version can be [inferred](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer) from the commit history (i.e. when the repository has no tagged releases yet) |
| [`preset`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#preset) | This option allows you to import one [preset configuration](https://mooltiverse.github.io/nyx/guide/user/configuration-presets/) into your configuration to save configuration time and effort |
| [`releaseLenient`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#release-lenient) | When this option is enabled (it is by default), Nyx will attempt to tolerate prefixes and other unnecessary characters (like leading zeroes) when **reading** Git tags from the commit history. When `true`, tags like `vx.y.x`, `relx.y.x` etc will be detected as release tags (for version `x.y.x`), regardless of the prefix Nyx uses to generate release names |
| [`releasePrefix`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#release-prefix) | It’s a common practice to add a leading string to version numbers to give releases a name. Common prefixes are v or rel but you might use anything, or no prefix at all |
| [`releaseTypesEnabled`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#enabled) | The comma separated list of release types that are enabled for the project. Here you can enable or disable the various release types, either custom or default. The list of [available release types](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`releaseTypesPublicationServices`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publication-services) | The comma separated list of service configuration names to be used to publish releases when the matched release type has the [`publish`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publish) flag enabled. The list of [available services](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/services/) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`releaseTypesRemoteRepositories`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#remote-repositories) | The comma separated list of remote repository names to be used to push changes to when the matched release type has the [`gitPush`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#git-push) flag enabled. The list of [available remote repositories](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/git/#remotes) is defined by the configured `preset` or a [configuration file](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`resume`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#resume) | When this flag is set to `true` Nyx tries to load an existing [state file](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) and resume operations from where it left when the state file was saved |
| [`scheme`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#scheme) | Selects the [version scheme](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/) to use. Defaults to [SEMVER](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/#semantic-versioning-semver) |
| [`sharedConfigurationFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#shared-configuration-file) | This option allows you to load a shared configuration file from a location other than [default ones](https://mooltiverse.github.io/nyx/guide/user/introduction/configuration-methods/#evaluation-order) |
| [`stateFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) | Enables the creation of the [state file](https://mooltiverse.github.io/nyx/guide/user/state-reference/) where Nyx stores its findings and generated values |
| [`summaryFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#summary-file) | Enables the creation of the summary file where Nyx saves a subset of relevant information from the internal state as name value pairs, easy to parse |
| [`verbosity`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#verbosity) | Controls the amount of output emitted by Nyx, where values are: `FATAL`, `ERROR`, `WARNING`, `INFO`, `DEBUG`, `TRACE` |
| [`version`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#version) | Overrides the version and prevents Nyx to [infer](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer). When overriding this value you take over the tool and go the manual versioning way so Nyx won’t try to read past versions from the commit history nor determine which identifiers to bump |

### Outputs

The following are the outputs from the action:

| Name                                                      | Notes |
| --------------------------------------------------------- | ----- |
| [`branch`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#branch) | This string contains the current Git branch name |
| [`bump`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#bump) | This string contains the name of the identifier that has been bumped to create the new `version`. Version identifiers depend on the selected version `scheme` |
| [`coreVersion`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#core-version) | This value is `true` when the `version` only uses *core* identifiers (i.e. is not a pre-release) according to the `scheme` |
| [`latestVersion`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#latest-version) | This value is `true` when the `version` is the latest in the repository, meaning that, according to the `scheme`, there are no other tags in the Git repository representing any version greater than `version` |
| [`newRelease`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#new-release) | This value is `true` when the `newVersion` is `true` and a new release with the current `version` has to be [issued](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#publish) |
| [`newVersion`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#new-version) | This value is `true` when the `version` is new and is basically a shorthand to testing if `version` is different than the `previousVersion` |
| [`scheme`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#scheme) | The configured [version `scheme`](https://mooltiverse.github.io/nyx/guide/user/introduction/version-schemes/) |
| [`timestamp`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#timestamp) | The timestamp in the Unix format (seconds since Jan 01 1970. (UTC). Example: `1591802533` |
| [`previousVersion`](https://mooltiverse.github.io/nyx/guide/user/state-reference/release-scope/#previous-version) | The version that was released before the one being created |
| [`primeVersion`](https://mooltiverse.github.io/nyx/guide/user/state-reference/release-scope/#prime-version) | The version that is used as the baseline when bumping version numbers when the release type uses [collapsed versioning](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/release-types/#collapse-versions) (the *pre-release* versioning) |
| [`version`](https://mooltiverse.github.io/nyx/guide/user/state-reference/global-attributes/#version) | The version that was [inferred](https://mooltiverse.github.io/nyx/guide/user/introduction/how-nyx-works/#infer), unless the [`version`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#version) configuration option was passed to override inference. When the version is not overridden or inferred the [`initialVersion`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#initial-version) is used |

All the above outputs are also contained in the [state file](https://mooltiverse.github.io/nyx/guide/user/state-reference/) (if enabled using the [`stateFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#state-file) option) or the summary file (if enabled using the [`summaryFile`](https://mooltiverse.github.io/nyx/guide/user/configuration-reference/global-options/#summary-file) option).

## Limitations

This is a [Docker Action](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions) so it's only available for Linux runners.

## Versioning

Although you can use a specific [version](https://github.com/mooltiverse/nyx-github-action/tags) for this action you are recommended to always use the latest version from the `main` branch (`uses: mooltiverse/nyx-github-action@main`).

This action always uses the latest version of the [Nyx Docker image](https://hub.docker.com/repository/docker/mooltiverse/nyx).

## Support

You can find support for Nyx by:

* browsing the [troubleshooting posts](https://mooltiverse.github.io/nyx/troubleshooting/), the [frequently asked questions](https://mooltiverse.github.io/nyx/faq/) and the available [examples](https://mooltiverse.github.io/nyx/examples/)
* searching the past [issues](https://github.com/mooltiverse/nyx/issues) or
* posting a new issue in case you can't find your questions covered by previous threads.

When posting issues please:

* provide detailed information to help us reproduce errors
* respect our [code of conduct](https://github.com/mooltiverse/nyx-github-action/blob/main/CODE_OF_CONDUCT.md)
* make it valuable for others that may find the same issue after you

## Badge

If you like Nyx please consider showing the badge [![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx) on your project page by inserting this snippet:

```md
[![](https://img.shields.io/badge/powered%20by-Nyx-blue)](https://github.com/mooltiverse/nyx)
```
