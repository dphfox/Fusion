# Contributions

We love contributions and suggestions from you guys! To make sure everything goes as smoothly as possible, we've set up a few processes you can follow for different contribution types:

<!----------------------------------------------------------------------------->

<details>
<summary>I have a question, or am stuck and need help using Fusion</summary>
<br>
Don't open an issue to ask a question - see our
<a href="https://elttob.github.io/Fusion/tutorials/#where-to-get-help">Get Started page</a>
to find places to get help! Our communities are always happy to help out new people 🙂
<hr>
</details>

<!----------------------------------------------------------------------------->

<details>
<summary>I found a security vulnerability or other sensitive issue</summary>
<br>
Please use our [vulnerability reporting process](./SECURITY.md). Do not openly
disclose sensitive bugs, issues or vulnerabilities - this is dangerous!
<hr>
</details>

<!----------------------------------------------------------------------------->
<details>
<summary>I found a non-security bug or issue</summary>
<br>
Here's our bug reporting process - you can click any step
for more info:
<br>
<details>
<summary>Check - are you the first person to report it?</summary>
<ul>
<li>Make sure to search for open issues *and* closed issues - it's possible
the behaviour you're reporting is not actually a bug, that someone else
opened an issue about it and then that issue was subsequently closed.</li>
<li>If an issue is found to be a duplicate, it is closed right away. We don't
want to split discussion about an issue across multiple locations.</li>
<li>If an issue was closed due to it being fixed, you may still open a new
issue describing the new regression.</li>
</ul>
</details>

<details>
<summary>Open a new GitHub issue, describing the bug</summary>
<ul>
<li>Your title should be clear, concise, and adequately summarise the issue.
Titles like 'Why is this broken?' and 'my code doesn't work' aren't helpful.</li>
<li>Include as much relevant information as possible. We can't diagnose the
issue if we don't know anything about it.</li>
<li>Please include simple, clear and easy-to-follow reproduction steps. You
can include a .rbxl file if you think it'd help us reproduce the issue!</li>
</ul>
</details>

<details>
<summary>We'll work with you to solve it</summary>
<ul>
<li>Bugs start out labelled as <b>'status: evaluating'</b>. This occurs as soon
as we notice the issue. At this stage, we have not verified the bug for
ourselves.</li>
<li>When the bug is verified, it will be labelled as <b>'status: needs design'</b>.
We'll start a discussion about how best to fix it.</li>
<li>Once a solution has been identified and approved. it will be labelled as
<b>'status: approved'</b></li>
<li>We'll close the issue once the fix is implemented in Fusion!</li>
</ul>
</details>

<hr>

A couple notes on etiquette:
<ul>
<li>Be patient - all project maintainers are voluteers, so it will likely take
some time to respond.</li>
<li>Don't bump or chase up your issue - commenting 'Any updates on this?' does
not add value to the conversation, and only clutters the issue.</li>
</ul>
<hr>
</details>

<!----------------------------------------------------------------------------->

<details>
<summary>I have an idea, suggestion or feature request</summary>
<br>
Here's our feature request process - you can click any step for more info:
<br>
<details>
<summary>Check - are you the first person to suggest it?</summary>
<ul>
<li>Make sure to search for open issues *and* closed issues - it's possible
your idea was already suggested and rejected. If you have a substantial case
for why it should not have been rejected, feel free to add to the existing
issue with your thoughts.</li>
<li>If an issue is found to be a duplicate, it is closed right away. We don't
want to split discussion about an issue across multiple locations.</li>
</ul>
</details>

<details>
<summary>Open a new GitHub issue, describing the feature request</summary>
<ul>
<li>Your title should be clear, concise, and adequately summarise the idea.</li>
<li>Avoid exclusively talking about specific solutions to problems - your
feature request should describe the general case for why a feature should be
added. Focus on who your feature request would help, when it would help them
and why.</li>
<li>That said, please feel free to suggest hypothetical API designs, as long
as they're not the focus. Remember that we value APIs that are as simple and
low-tech as possible!</li>
</ul>
</details>

<details>
<summary>We'll work with you to develop it further</summary>
<ul>
<li>Requests start out labelled as <b>'status: evaluating'</b>. This occurs
as soon as we notice the issue. At this stage, we are gathering community
sentiment and evaluating whether the idea fits well with Fusion.</li>
<li>If we like the general idea, it will be labelled as <b>'status: needs design'</b>
This means we would like to include your suggestion, but don't have a solid idea
of how it should look and function in Fusion.</li>
<li>Once a design has been discussed and approved. it will be labelled as
<b>'status: approved'</b></li>
<li>We'll close the issue once the feature is implemented in Fusion!</li>
</ul>
</details>

<hr>

New features are hard to get right! To help you design your feature request, we
have some tips you could consider:
<br>
<details>
<summary>Design for declarative coding</summary>
Fusion is designed around <i>declarative code</i>; an end user of Fusion should
be able to describe what they want to happen, without specifying how exactly the
computer should get there. 

The more that Fusion can figure out on it's own, the better it usually is for
the developer.
</details>

<details>
<summary>Guide developers towards faster code</summary>
Sometimes it's hard to read and write fast code - developers might choose
suboptimal coding patterns if the optimal code is hard to maintain.

Developers always appreciate features that let them write fast programs without
sacrificing readability or maintainability.
</details>

<details>
<summary>Make it harder to mess up</summary>
Developers aren't perfect, and often make mistakes! The best features are those
which handle easy-to-mess-up stuff on behalf of the developer, and make any
developer mistakes obvious and easy to fix.
</details>

<details>
<summary>Keep developers' code easy to read</summary>
Code is written once, but it's read and maintained perpetually. With this in
mind, always aim to reduce the effort needed to read and maintain code, even if
it's at the expense of some ease of writing.
</details>

<hr>

We also have some guidelines for what kind of features we tend to reject:
<br>
<details>
<summary>Overly specific features</summary>
Fusion works best as a flexible, general base that people can build their own
specific tooling on top of. Niche features often would be better served as part
of third party libraries.
</details>

<details>
<summary>Focused on writing code only / 'saving keystrokes'</summary>
We shouldn't look for ways to 'save keystrokes' because this often hurts code
readability. Code is written once, but reviewed and understood many times, so we
should optimise for that instead.
</details>

<details>
<summary>Depends on metatables / getfenv / magic features</summary>
It's almost always possible to express an idea with simple function and table
primitives; simpler implementations are less buggy, easier to understand for
maintainers and users, and often more performant.

(the one exception to this rule is garbage collection - while we don't
like relying on it, it's sometimes a necessary evil for the benefit of the
developer)
</details>
<hr>
</details>

<!----------------------------------------------------------------------------->

<details>
<summary>I want to make a code modification or open a pull request</summary>
<br>

While we do accept community pull requests, please observe that Fusion has a
very high bar for code and API quality. We're used by a lot of important people
and projects!

<hr>

Here's our code contributions process - you can click any step for more info:

<details>
<summary>Get your idea or bug approved before writing any code</summary>
<ul>
<li>While we appeciate the initiative to implement your own features in your own
time, we want to make sure everything in Fusion is well designed and considered.
Pull requests are not the best place to suggest new features suddenly!</li>
<li>Open an issue describing your feature request or bug report first (using the
guidelines from above), and make sure it gets <b>'status: approved'</b>.</li>
</ul>
</details>

<details>
<summary>Create a new branch and draft a pull request</summary>
<ul>
<li>It's good to describe what you're working on, why you're working on it and
what you aim to achieve with the pull request.</li>
<li>Keep your pull requests small and specifically targeted; for example, by
separating different features into different pull requests.</li>
<li>Doing this as early as possible means we can observe and comment on your
work as you go, enabling us to help you or to point out potential
shortcomings while it's still early on and easy to rectify.</li>
</ul>
</details>

<details>
<summary>Write your code</summary>
<ul>
<li>Make sure to read our <a href="./style-guide.md">style guide document</a>
and observe how code near your working area is written. Consistent code is much
easier to maintain, and avoids style arguments.</li>
<li>Stay focused - only make changes to what you set out to work on. If you want
to change other stuff, it's better to do in another pull request focused on that.</li>
</ul>
</details>

<details>
<summary>We'll review your changes</summary>
<ul>
<li>Nobody writes flawless code first time - nobody's perfect. You will almost
certainly be asked to make changes as part of this process, so please be
patient with us.</li>
<li>Feel to voice your opinion if you disagree with any suggested changes, but
keep it respectful and focused on the code, not the reviewer.</li>
<li>If we decide your pull request doesn't quite align with Fusion,
then we'll explain in as much detail as possible why we don't want to merge it.
Don't take this personally - some PRs are fantastic, but just in the wrong place
or proposed at the wrong time.</li>
<li>If your code passes code review, your changes will be approved. They may then
be merged into the main Fusion codebase at a later time.</li>
</ul>
</details>
<hr>
</details>