# 0003 Limit AWS actions for most users in the new account

## Context

We want to limit cost, environmental impact and security risk of the engineering
sandbox account.

[AWS' SCP](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
allow the definition of a maximum set of permissions that a principal may use
within an account. [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
represent the specific set of permissions granted to a principal. Using these
two tools it is possible to limit the set of actions someone can take without
stopping them doing what they need to (i.e. deploying an EKS cluster).

The recommended [eksctl AWS IAM permissions](https://eksctl.io/usage/minimum-iam-policies/)
includes several high risk permissions (e.g. `iam:CreatePolicy`) which represent
privilege escalation routes. The `iam:*` permissions are needed to do three
things:
* Create and pass a role to the eks service (the cluster role)
* Create and pass a role to the ec2 service (the node role)
* Create any missing service-linked roles

The two roles are generally expected to use AWS managed policies.

## Decision

An SCP will [define](https://github.com/weaveworks/corp-infra/blob/main/engineering_account.tf)
the maximum set of permissions that a user may have. It will also require all
resources be deployed into the `eu-north-1` region.

An 'editor' role will be created that only has permission to pass the cluster and
node roles.

The two required EKS roles (the cluster role and the node role) will be created
outside of eksctl to reduce the number of permissions it needs (the
service-linked roles will similarly be created).

The roles will used the AWS managed policies

## Consequences

Normal users will not be able to create, modify or delete `iam` resources
(policies, users or roles).

If new policies need to be added to the roles then they will need to be updated
(although this is unlikely as AWS will likely make changes directly to their
managed roles).

By using the `eu-north-1` region we use the region with the lowest environmental
impact as well as limiting the risk of resources being created in un-monitored
regions.

By using the SCP we also reduce the risk of un-expected services being used.
