# Contributing

We're happy you're reading this and willing to contribute! We also appreciate if you read through this document to help us accepting your contributions.

This project and everyone participating in it is governed by the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Issues

Feel free to open new [issues](https://github.com/mooltiverse/nyx-github-action/issues) for bugs and support requests. Before doing so we ask you to:

1. search for similar requests that might have been opened in the past to avoid repetitiveness
2. read through the [docs](https://mooltiverse.github.io/nyx/) and see if a similar was already addressed. Also read through the [examples](https://mooltiverse.github.io/nyx/examples/)
3. make sure you're running the [latest release](https://github.com/mooltiverse/nyx-github-action/releases)
4. consider to open the issue on the [main project](https://github.com/mooltiverse/nyx/issues)

If you can't find any answer, when submitting a new issue please provide as much information as you can to help us understand. Don't forget to:

* include a **clear title and description**
* give as much relevant information as possible, which may include a code snippet or an executable test case
* give instructions on how to reproduce the problem
* describe the expected behavior and the current behavior
* tell us about the kind of deliverable you're using and their version and describe the environment so we can reproduce it

We will do our best to take relevant requests and update the documentation or publish a new [example post](https://mooltiverse.github.io/nyx/examples/) about the specific use case in order to make it reusable by others.

### Version scheme

This project is versioned according to [Semantic Versioning](https://semver.org/).

## Code and Documentation

If you're going to contribute with code or documentation please read through the following sections. When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the repository owners.

### Branching strategy and commits

This project uses the [GitHub flow](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/github-flow) branching strategy. Before contributing make sure you have a clear understanding of it.

### Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/) so please give commit messages the same format, like:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

One-line messages are fine for small changes, for example:

```bash
$ git commit -m "feat: brand new feature added"
```

while for bigger changes additional description in the body is welcome, like:

```bash
$ git commit -m "feat: brand new feature added
>
> Here is the detailed description of what has changed."
```

Allowed *types* are:

* `feat`: new features
* `fix`: a bug fix
* `build`: changes that affect the build system or external dependencies
* `chore`: various changes not falling into other categories
* `ci`: changes to CI configuration files and scripts
* `docs`: documentation only changes
* `style`: changes that do not affect the meaning of the code but just its coding stye
* `refactor`: code changes that neither fix bugs nor add features
* `perf`: changes affecting performances
* `test`: changes on the test code and suites

Comments using the `feat` type will bump the [minor](https://semver.org/) number while those using the `fix` type bump the [patch](https://semver.org/) number. Other types do not bump any version number.

Breaking changes must have an exclamation mark at the end of the *type* (i.e. `feat!: brand new feature added`) or a body line starting with `BREAKING CHANGE:` (i.e. `BREAKING CHANGE: this feature breaks backward compatibility`). Breaking changes will bump the [major](https://semver.org/) number.

Allowed *scopes* are:

* `config`: the change affects the configuration
* `core`: the change affects the core logic

Other scopes will be added in the future.

### Prerequisites

You can work on the project on any platform (Linux, Windows, Mac). You need to have installed:

* [Git](https://git-scm.com/)
* [Docker CE](https://docs.docker.com/install/)

You also need a local copy of the repository that you can get by running:

```shell script
$ git clone https://github.com/mooltiverse/nyx-github-action.git
```

You can use any IDE, just make sure you don't clutter the repo with IDE files.

### Contributing Code

When contributing code make sure that you also provide extensive tests for the changes you make and that those tests achieve a sufficient coverage.
