# Contributions

We love contributions and suggestions from you guys! To make sure everything goes as smoothly as possible, we've set up a few processes you can follow for different contribution types:

-----

## I need help or have a question

Whatever you're looking for, here are some resources for you to get help!

- [The Roblox OSS Discord](https://discord.gg/h2NV8PqhAD) has a [#fusion](https://discord.com/channels/385151591524597761/895437663040077834) channel
- Check out [our Discussions page](https://github.com/Elttob/Fusion/discussions) on GitHub

Please don't submit issues to the repository to ask a question. Prefer to start a
discussion instead :)

-----

## I found a bug

### Are you the first person to report it?

- Make sure to search for open issues *and* closed issues - it's possible
someone else opened an issue about it and then that issue was subsequently
closed.

- If an issue is found to be a duplicate, it is closed right away. We don't
want to split discussion about an issue across multiple locations.

- If an issue was closed after a bug fix, but the bug has come back, it's
best to open a new issue describing the new variant of the bug.


### Open a new issue, describing the bug

- Your title should be clear and concise; summarise the issue adequately.
Titles like 'Why is this broken?' and 'my code doesn't work' aren't helpful.

- Include as much relevant information as possible. We can't diagnose the
issue if we don't know anything about it.

- Please include simple, clear and easy-to-follow reproduction steps. You
can include a .rbxl file to help us see the bug in action.

### We'll work with you to solve it

- The issue will be closed when a fix has been implemented, verified to work
and is merged into a main branch of Fusion.

- Please be patient - all project maintainers are volunteers, so it will likely
take some time to respond.

- Don't bump or chase up your issue - commenting 'Any updates on this?' does
not add value to the conversation, and only clutters the issue.

-----

## I have an idea, suggestion or feature request

### Are you the first person to suggest it?

- Make sure to search for open issues *and* closed issues - it's possible
your idea was already suggested and rejected.

- If you have a substantial case for why it should not have been rejected,
feel free to add to the existing issue with your thoughts.

- If an issue is found to be a duplicate, it is closed right away. We don't
want to split discussion about an issue across multiple locations.

### Open a new issue, describing the feature request

- Your title should be clear, concise, and adequately summarise the idea.

- Avoid exclusively talking about specific solutions to problems - your
feature request should describe the general case for why a feature should be
added. Focus on who your feature request would help, when it would help them
and why.

- That said, please feel free to suggest hypothetical API designs, as long
as they're not the focus.

### We'll work with you to develop it further

- Most feature requests originate from valid concerns, but might need work to
craft an API that's suitable for Fusion.

- We'll close the issue once an implementation of the design is approved and
merged into a main branch of Fusion.

### Tips for good feature requests

- We typically prefer users declaring information upfront, rather than
procedural solutions that depend on execution order.

- Guide users towards writing code that's more optimal, but not at the expense
of maintainability.

- Features should be designed so mistakes by the developer are easy to spot.

### Things to avoid in feature requests

- Overly specific solutions. Niche features often would be better served as
part of third party libraries; Fusion deals with concerns that everyone has an
interest in.

- 'Saving keystrokes'. Code is read many times, but written very few times.
Shortening code is not a strong enough reason to include a feature, and can
actually harm readability and maintainability quite seriously.

- Overengineering. It's almost always possible to express an idea with simple
function and table primitives. Simpler implementations are less buggy, easier
to understand for maintainers and users, and often more performant.

-----

## I want to contribute code

### Respect the issues

- New features without existing feature requests are closed on principle. Pull
requests aren't the place to introduce new ideas suddenly.

- Please don't implement new features before they're ready to be implemented;
*this has happened a lot.* We often end up throwing out a lot of work because
the design was not yet approved and ended up changing direction.

- Bug fixes without existing bug reports are passable, but information about
the bug must be provided, like a regular bug report would contain.

### Create a new branch and draft a pull request

- Create a pull request as soon as possible and mark it as a draft while you
are working on it. This means we can see what you're working on and guide you
as you work, rather than lumping all feedback at the end of the process.

- Ensure it's clear what you're working on, why you're working on it and what
you aim to achieve with the pull request.

- Keep your pull requests small and specifically targeted; for example, by
separating different features into different pull requests.

### Write your code

- Make sure to read our <a href="./style-guide.md">style guide document</a>
and observe how code near your working area is written. Consistent code is much
easier to maintain, and avoids style arguments.

### We'll review your changes

- You will almost certainly be asked to make changes as part of this process -
please be patient with us. It's not personal.

- Feel free to voice your opinion if you disagree with any suggested changes,
but keep it respectful and focused on the code, not the reviewer.

- If we decide your pull request doesn't quite align with Fusion, then we'll
explain in as much detail as possible why we don't want to merge it. We never
close pull requests for personal reasons.
