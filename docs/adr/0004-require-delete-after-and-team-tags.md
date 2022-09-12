# Require 'delete-after' and 'team' tags

## Context

The contents of the Engineering Sandbox account are expected to be ephemeral. As
such we want to have easy ways to know what can and cannot be deleted. This both
helps reduce cost and maintenance costs by removing overhead as to what is
needed.

## Decision

Use AWS' [tagging policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html)
to require all resources in the Engineering Sandbox account have the following
tags:

* team -- with a value indicating the team that created the resources
* delete-after -- with a date after which the resource can definitely be deleted
  (this does not guarantee that it won't be deleted before this date).

## Consequences

All resources should have a team and delete-after tag.

All resources with a delete-after tag in the past can be safely deleted.

Any resources with a delete-after tag in the future can have the owning team
quickly found in case it needs to be deleted or otherwise modified.

Which teams are using which resources can be easily tracked for billing and UX
purposes.
