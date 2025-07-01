---
sidebar_position: 13
sidebar_label: Collaboration / Orgs
---

# Collaboration and Orgs

While so far Planto is mainly focused on a single-user experience, we plan to add features for sharing, collaboration, and team management in the future, and some groundwork has already been done. **Orgs** are the basis for collaboration in Planto.

## Multiple Users

Orgs are helpful already if you have multiple users using Planto in the same project. Because Planto outputs a `.planto` file containing a bit of non-sensitive config data in each directory a plan is created in, you'll have problems with multiple users unless you either get each user into the same org or put `.planto` in your `.gitignore` file. Otherwise, each user will overwrite other users' `.planto` files on every push, and no one will be happy.

## Domain Access

When starting out with Planto and creating a new org, you have the option of automatically granting access to anyone with an email address on your domain.

## Invitations

If you choose not to grant access to your whole domain, or you want to invite someone from outside your email domain, you can use `planto invite`:

```bash
planto invite
```

## Joining an Org

To join an org you've been invited to, use `planto sign-in`:

```bash
planto sign-in
```

## Listing Users and Invites

To list users and pending invites, use `planto users`:

```bash
planto users
```

## Revoking Users and Invites

To revoke an invite or remove a user, use `planto revoke`:

```bash
planto revoke
```
