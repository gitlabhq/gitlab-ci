# Contribute to GitLab CI

This guide details how contribute to GitLab CI.

### Issue tracker guidelines

**[Search the issues](https://gitlab.com/gitlab-org/gitlab-ci/issues)** for similar entries before submitting your own, there's a good chance somebody else had the same issue. Show your support with `:+1:` and/or join the discussion. Please submit issues in the following format (as the first post):

1. **Summary:** Summarize your issue in one sentence (what goes wrong, what did you expect to happen)
2. **Steps to reproduce:** How can we reproduce the issue
3. **Expected behavior:** Describe your issue in detail
4. **Observed behavior**
5. **Relevant logs and/or screenshots:** Please use code blocks (\`\`\`) to format console output, logs, and code as it's very hard to read otherwise.
6. **Possible fixes**: If you can, link to the line of code that might be responsible for the problem

## Merge requests

We welcome merge requests with fixes and improvements to GitLab code, tests, and/or documentation. The features we would really like a merge request for are listed with the [status 'accepting merge/merge requests' on our feedback forum](http://feedback.gitlab.com/forums/176466-general/status/796455) but other improvements are also welcome.

### Merge request guidelines

If you can, please submit a merge request with the fix or improvements including tests. If you don't know how to fix the issue but can write a test that exposes the issue we will accept that as well. In general bug fixes that include a regression test are merged quickly while new features without proper tests are least likely to receive timely feedback. The workflow to make a merge request is as follows:

1. Fork the project on GitLab Cloud
1. Create a feature branch
1. Write tests and code
1. Add your changes to the [CHANGELOG](CHANGELOG)
1. If you have multiple commits please combine them into one commit by [squashing them](http://git-scm.com/book/en/Git-Tools-Rewriting-History#Squashing-Commits)
1. Push the commit to your fork
1. Submit a merge request (MR)
1. The MR title should describes the change you want to make
1. The MR description should give a motive for your change and the method you used to achieve it
1. If the MR changes the UI it should include before and after screenshots
1. Link relevant [issues](https://gitlab.com/gitlab-org/gitlab-ci/issues) and/or [feedback items](http://feedback.gitlab.com/) from the merge request description and leave a comment on them with a link back to the MR
1. Be prepared to answer questions and incorporate feedback even if requests for this arrive weeks or months after your MR submittion

Please keep the change in a single MR as small as possible. If you want to contribute a large feature think very hard what the minimum viable change is. Can you split functionality? Can you only submit the backend/API code? Can you start with a very simple UI? The smaller a MR is the more likely it is it will be merged, after that you can send more MR's to enhance it.

We will accept merge requests if:

* The code has proper tests and all tests pass (or it is a test exposing a failure in existing code)
* It can be merged without problems (if not please use: `git rebase master`)
* It does not break any existing functionality
* It's quality code that conforms to the [Ruby](https://github.com/bbatsov/ruby-style-guide) and [Rails](https://github.com/bbatsov/rails-style-guide) style guides and best practices
* It is not a catch all merge request but rather fixes a specific issue or implements a specific feature
* It keeps the GitLab code base clean and well structured
* We think other users will benefit from the same functionality
* It is a single commit (please use `git rebase -i` to squash commits)
