# How To Contribute

Fusion welcomes issues and pull requests from the community! However, make sure
you've read the following first *before* opening any issues or pull requests, so
the process can be as smooth as possible 🙂

## I have a question, or am stuck and need help using Fusion
Don't open an issue to ask a question - see our
[Get Started page](https://elttob.uk/Fusion/tutorials/#where-to-get-help)
to find a place to get help.

## I found a security vulnerability or other sensitive issue
Please use our [vulnerability reporting process](./SECURITY.md). Do not openly
disclose sensitive bugs, issues or vulnerabilities - this is dangerous!

## I found a non-security bug or issue
We're always looking for bug reports to make sure Fusion is the best it can be!
While we do maintain unit tests and thoroughly check our work, sometimes issues
can slip through. Here's what to do when you find one:
- ***You're likely not the first person to report it.*** Please search for
your issue in our Issues section before you open a new issue.
	- Make sure to search for open issues *and* closed issues - it's possible
	the behaviour you're reporting is not actually a bug, that someone else
	opened an issue about it and then that issue was subsequently closed.
	- If an issue is found to be a duplicate, it is closed right away. We don't
	want to split discussion about an issue across multiple locations.
	- If an issue was closed due to it being fixed, you may still open a new
	issue describing the new regression.
- Only if you can't find an existing issue, you may open a new issue describing
your bug.
	- Your title should be clear, concise, and adequately summarise the issue.
	Titles like 'Why is this broken?' and 'my code doesn't work' aren't helpful.
	- Include as much relevant information as possible. We can't diagnose the
	issue if we don't know anything about it.
	- Please include simple, clear and easy-to-follow reproduction steps. You
	may include a .rbxl file if you need some existing non-trivial setup.
- When your issue is noticed by a project maintainer, it will be labelled
appropriately.
	- Bugs start out labelled as **'status: evaluating'**. This occurs as soon
	as we notice the issue. At this stage, we have not verified the bug for
	ourselves.
	- When the bug is verified, it will be labelled as **'status: needs design'**
	if there is not an obvious or immediately actionable solution. This often
	occurs with bugs whose fixes would be breaking changes.
	- Once a solution has been identified and approved. it will be labelled as
	**'status: approved'**. Approved bugs will be fixed in a future version of
	Fusion, and will be closed once the fix ships.
- Be patient - all project maintainers are voluteers, so it will likely take
some time to respond.
	- Don't bump or chase up your issue - commenting 'Any updates on this?' does
	not add value to the conversation, and only clutters the issue.

## I have an idea, suggestion or feature request
We have some guidelines for what kind of features we're looking for:

- **Allows the expression of imperative code in a more declarative style** - i.e.
users can think in terms of what they want to accomplish, not the steps or
instructions the computer must follow to achieve it.
- **Helps avoid suboptimal code and provides useful optimisation by default** -
i.e. users are led towards patterns that allow for caching and avoid expensive
processes.
- **Allows the library to handle certain parts of code that are very easy to
mess up** - i.e. user code is always internally consistent and doesn't behave
strangely in edge cases.
- **Makes code that isn't self evident easier to read** - i.e. users don't have
to wade through massive amounts of syntax to implement a simple concept.

We also have some guidelines for what kind of features we tend to reject:

- **Does not serve a majority of users** - Fusion should be a base that people
can build their own specific tooling on top of. More niche features would be
better served by being part of third party libraries.
- **Only serves code writability** - we shouldn't look for ways to 'save
keystrokes' because this hurts code readability. Code is written once, but
reviewed and understood many times, so we should optimise for that instead.
- **Depends on magic Luau** - in particular, metatables and function environment
manipulation are worst offenders. It's almost always possible to express an idea
with simple function and table primitives; simpler implementations are less
buggy, easier to understand for maintainers and often more performant.
	- (the one exception to this rule is garbage collection - while we don't
	like relying on it, it's sometimes a necessary evil for the benefit of the
	user)

If you believe your idea fits what we like to see, please continue:
- ***Someone else may have suggested it already.*** Please search for
your idea in our Issues section before you open a new issue.
	- Make sure to search for open issues *and* closed issues - it's possible
	your idea was already suggested and rejected. If you have a substantial case
	for why it should not have been rejected, feel free to add to the existing
	issue with your thoughts.
	- If an issue is found to be a duplicate, it is closed right away. We don't
	want to split discussion about a suggestion across multiple locations.
- Only if you can't find an existing issue, you may open a new issue describing
your feature request.
	- Your title should be clear, concise, and adequately summarise the idea.
	- Avoid exclusively talking about specific solutions to problems - your
	feature request should describe the general case for why a feature should be
	added. Focus on who your feature request would help, when it would help them
	and why.
	- That said, please feel free to suggest hypothetical API designs, as long
	as they're not the focus. Remember that we value APIs that are as simple and
	low-tech as possible.
- When your issue is noticed by a project maintainer, it will be labelled
appropriately.
	- Enhancements start out labelled as **'status: evaluating'**. This occurs
	as soon as we notice the issue. At this stage, we are gathering community
	sentiment and evaluating whether the idea aligns with our vision for Fusion.
	- If we like the general idea, it will be labelled as **'status: needs design'**
	This means we would like to include your idea, but don't have a solid idea
	of how it should look and function in Fusion.
	- Once a design has been identified and approved. it will be labelled as
	**'status: approved'**. Approved features will be fixed in a future version
	of Fusion, and will be closed once the feature ships.
- Be patient - all project maintainers are voluteers, so it will likely take
some time to respond.
	- Don't bump or chase up your issue - commenting 'Any updates on this?' does
	not add value to the conversation, and only clutters the issue.

## I want to make a code modification or open a pull request

While we do accept community pull requests, please observe that Fusion is still
a largely controlled project. This is not out of hostility to our contributors,
but instead because Fusion is used in a lot of high profile projects, and has a
very high bar for code and API quality.

- If you intend to work on a pull request, feel free to create a new branch and
open a draft pull request early on, describing what you're working on, why you're
working on it and what you aim to achieve with the pull request.
	- Doing this as early as possible means we can observe and comment on your
	work as you go, enabling us to help you or to point out potential
	shortcomings while it's still early on and easy to rectify.
- **Make sure your changes correspond to an approved issue.** While we appeciate
the initiative to implement your own features in your own time, we want to make
sure everything in Fusion is well designed and considered. Pull requests are not
the place to suggest new features.
	- While we heavily discourage it, we do make exceptions for some bug fixes,
	typically trivial ones that are easy to approve. *Do not depend on this
	process* - we reserve the right to close your pull request and manually
	redirect you to a new or existing issue instead.
- Avoid cosmetic changes, such as renaming, refactoring, or code formatting - if
a pull requests attempts to change the coding convention, is centred around the
reorganisation of code, or generally doesn't focus on stability, functionality
or testability, it will almost always be rejected. [The Rails maintainers have a
great explanation on why these changes are not desirable.](https://github.com/rails/rails/pull/13771#issuecomment-32746700)
	- This includes, but is not limited to, changing the spelling of variable
	names, changing whitespace and newlines in code, switching between tabs and
	spaces, renaming internal functions, rearranging function parameters, and
	regrouping code into different folders.
- Make sure all your changes follow global and local coding convention. Make
sure to read our [style guide document](./style-guide.md) and observe how code
near your working area is written. Consistent code is much easier to maintain,
and avoids style arguments.
	- In particular, make sure that variable and function names are written to
	the same standard as other Fusion code. Naming is where a lot of code falls
	short, and leads to massive readability problems if left unchecked. We will
	not hesitate to point these things out in code review.
- When your pull request is noticed by a project maintainer, it will be subject
to a code review.
	- Nobody writes perfect code first time - we're all humans. You will almost
	certainly be asked to make changes as part of this process, so please be
	patient with us, and make sure to voice your opinion if you disagree with
	any suggested changes or rationale so we can make your PR the best it can be!
- Alternatively, if we decide your pull request doesn't quite align with Fusion,
then we'll explain in as much detail as possible why we don't want to merge it.
Don't take this personally - some PRs are fantastic, but just in the wrong place
or proposed at the wrong time.
- If your code passes code review, your changes will be approved. They may then
be merged into the main Fusion codebase at a later time, subject to conditions
around what we intend to include in different Fusion versions.
	- Sometimes, we may decide to merge your code, but disable it behind a flag.
	This is often used to disable features we don't want to make public until
	some other pull requests are implemented or further design work is done.
- We always make sure to credit pull requests and their contributors in release
notes.