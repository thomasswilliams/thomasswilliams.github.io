---
layout: post
title:  "Different SSH keys for different purposes"
date:   2026-04-06 12:00:00 +1100
categories: general
---

I have different SSH keys for different purposes - one for GitHub, one for GitLab, Azure SSH, other servers etc. Keys for different accounts too - work or personal. Some Git hosting sites allow SSH keys for signing commits; a _signing_ SSH key can be different than the _authorisation_ SSH key.

<div markdown="1" class="note">
Reminder: an SSH key is basically you. If someone has access to an SSH private key, they can impersonate you, and systems can't tell the difference. SSH keys aren't the problem, they're great - but need to be secured, and differentiated. This post is about the latter.
</div>
<br/>

Having specific keys helps with exposure if a key is copied without your knowledge, or decrypted, as well as rotating. Rotating SSH keys is considered best practice, and having a key that's limited in scope makes it easier to rotate over a single key that accesses, well, everything.

Here's how I do different SSH keys for different purposes, on Linux or Mac, as at early 2026.

But first:

- **naming**: I suggest naming the key with it's purpose and the year created, as well as the algorithm
- **passphrase**: SSH keys should be protected with a passphrase, with the passphrase being different than your password

## An example of creating a specific, named SSH key

As an example, I'll generate an SSH key for Codeberg (a new, free Git hosting site) by running the following command:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/codeberg_ed25519_thomas_williams_2026 -a 100 -C "Thomas Williams <https://codeberg.org/thomasswilliams>"
```

- the key will use the "ed25519" algorithm, a strong algorithm recommended by Codeberg, Mozilla, GitHub and others (see this excellent guide at <https://infosec.mozilla.org/guidelines/openssh>, as well as other references at the bottom of this post)
- the key will have a meaningful name - don't leave it blank which will use the default name, potentially overwriting/destroying existing keys
- I use my profile URL as a comment (I could use my e-mail address)
- `-a` is rounds of derivation, making the key harder to brute-force

I enter a passphrase when prompted. If everything goes right, I now have two new files in my _~/.ssh_ directory "codeberg_ed25519_thomas_williams_2026" (private key) and "codeberg_ed25519_thomas_williams_2026.pub" (public key).

As there are now multiple keys in my _~/.ssh_ directory, I can specify which site or server uses which key in the _~/.ssh/config_ file as per <https://stackoverflow.com/a/4246809>. Doing this means I don't need to pass the key file name to SSH commands:

```conf
# Codeberg
Host codeberg.org
  # for the specified host
  HostName codeberg.org
  # always uses "git" user
  User git
  # specify the key file for Codeberg
  IdentityFile ~/.ssh/codeberg_ed25519_thomas_williams_2026
```

I also need to add the public key part of the new SSH key to Codeberg - see their help at <https://docs.codeberg.org/security/ssh-key/>.

Once I've added the key to Codeberg, I can test that it works from a command line:

```bash
ssh -T git@codeberg.org
```

(If you have issues, make sure the _~/.ssh/config_ file is set to user read-write only, with no other access, by running: `chmod 600 ~/.ssh/config`. It may be worth reviewing permissions on _~/.ssh_ and _~/.ssh/authorized\_hosts_, as incorrect permissions can be a common cause of login problems.)

Because this key will be used for Git operations, I can also tell Git on a per-repo basis about the key, running the following from a command line in the repo directory:

```bash
git config core.sshCommand "ssh -i ~/.ssh/codeberg_ed25519_thomas_williams_2026"
```

Don't forget to back up your SSH keys (password managers are a good option to do this to). Happy - and secure - SSH keying!

**References:**
- <https://unterwaditzer.net/2025/codeberg.html>
- <https://www.ssh.com/academy/secrets-management/password-key-rotation#how-often-should-you-rotate-passwords>
- <https://docs.aws.amazon.com/transfer/latest/userguide/keyrotation.html>
- <https://www.beyondtrust.com/blog/entry/ssh-key-management-overview-6-best-practices>
- <https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent>
- <https://dev.to/sebos/ssh-authentication-key-rotation-why-and-how-to-expire-ssh-keys-3hfg>
- <https://www.brandonchecketts.com/archives/ssh-ed25519-key-best-practices-for-2025>