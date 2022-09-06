# [0002] Use A New Engineering Sandbox AWS Account

## Context

As covered in [ADR 0001: Use ekstcl for MVP engineer cluster creation](./0001-use-eksctl-for-mvp-engineer-cluster-creation.md)
we will be creating AWS EKS clusters for use by engineers. These clusters will
need to be created in an AWS account.

One of the aims of the engineering cluster project is to make sure the clusters
are short lived and easy to manage or replace as well as secure.

Weaveworks currently has [20 accounts](https://www.notion.so/weaveworks/3799bd62e5d64fbcb1c1a6e201e44117?v=b0767921e3f9490e8fc3079ecbd73be3)
managed as part of an [AWS Organization](https://aws.amazon.com/organizations/).
Most of these have dedicated uses (e.g. 'CTO', 'Marketplace', 'Demo') with access
managed by IT.

Any account should be fully controlled by engineering and all resources deployed
to it should be done so with the understanding that they are short-lived.

## Decision

Add a new AWS account for use solely by engineers.

## Consequences

The account can have all resources deleted at any time.

The account will not be connected to any other infrastructure so that potentially
unsafe sytems can be deployed to it without presenting a security risk.

IAM roles for the account can be configured to limit actions to only those
required to deploy EKS clusters.
