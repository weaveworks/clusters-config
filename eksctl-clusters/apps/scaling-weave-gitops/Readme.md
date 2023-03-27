# Scaling Weave Gitops

Scaling weave gitops is an application to help us measuring progress
in the context of
the [scaling gitops initiative](https://www.notion.so/weaveworks/Scaling-Weave-Gitops-Observability-Phase-3-7e0a1cfcc89641c9bb05a05c5356af34?pvs=4)

The idea is that

- the initiative defines a set of OKRs
- we need somehowe to udnerstand and measure these okrs

This application provides that via

- synthetic monitoring
- other monitoring / observability artifacts

## FAQ

### How can i see progress?

In grafana scaling
board https://grafana-wge-2448.eng-sandbox.weave.works/d/3g264CZVzA/scaling-weave-gtiops?from=now-5m&to=now

### How can i contribute?

If you want to add a synthetic traffic scenario you add it [here](synthetic-traffic/wge/cypress/e2e)

They are organised around objectives from the initiative

See an example for [objective 3](./synthetic-traffic/wge/cypress/e2e/objective3)

### How can i run the tests?

You could run them via cypress or makefile

Running them via crypress:

```
npx cypress run --spec "cypress/e2e/objective3/**/*"
```

Running them via make:

make run-objective-3

```bash
➜  synthetic-traffic git:(add-scaling-o3) ✗ make run-objective3                                                                                                                                                                      <aws:sts>
npx cypress run --spec "cypress/e2e/objective3/**/*"
...
  (Run Finished)


       Spec                                              Tests  Passing  Failing  Pending  Skipped
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ✔  kr1-results-are-complete.cy.js           00:02        2        2        -        -        - │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘
    ✔  All specs passed!                        00:02        2        2        -        -        -

```

### How do i build the tests?

Use `make build` to build the docker image

### How can i deploy the tests?

They are an application deployed in https://wge-2448.eng-sandbox.weave.works using
this [kustomization](./kustomization.yaml)

### How do i build the grafana dashboard?

against the This is an application to measure progress of

how to measure slos

1. tag tests
2. run them via jobs
3. measure metrics via kube state metrics

`cypress run --record --tag "staging"`

https://github.com/kubernetes/kube-state-metrics/blob/main/docs/job-metrics.md

sli = good events / total event
good events = jobs succeded over time
total events = total jobs executed

therefore steps are

1. given a job - for example O3
2. when scheulded over time
3. then sli and slo calculated based on the previous metrics

