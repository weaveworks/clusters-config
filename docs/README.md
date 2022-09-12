# Docs

## ADRs

We will try using [ADRs](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions.html)
to capture why certain decisions have been made as well as any foreseen
consequences.

Each ADR should have:
* A title and an ID
  - e.g. '101 -- we will use RDS to store terraform state'
  - The title should be a descriptive summary of the decision
  - The ID is mostly to preserve the order in which ADRs are created
* A context section
  - e.g. 'Terraform needs a new state store after problems due to eventual
    consistency in S3. We would like the new store to be ACID compliant'
  - This should capture what problem is being solved and why
* A decision section
  - e.g. 'AWS RDS postgres will be used as a state store'
  - Capture what was decided. This may just be the title again or may have some
    sub-decisions if relevant (although avoid implementation details)
* A consequences section
  - e.g. 'We will need to provision an RDS instance with regular backups and maintenance'
  - This should capture what will happen because of the decision, both the good
    and the bad.
  - If there were other options considered this is a good place to summarise them
