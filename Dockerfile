FROM docker.io/kubernetesui/dashboard-web:1.7.0 AS baseimage

FROM ubuntu:20.04 AS builder

COPY --from=baseimage /public /public

RUN /usr/bin/find /public -type f -name "*.css" -exec /usr/bin/sed -i 's/.mat-select-panel{/.mat-select-panel{max-height: 700px !important;/' {} +;

# Scratch can be used as the base image because the backend is compiled to include all
# its dependencies.
FROM docker.io/kubernetesui/dashboard-web:1.7.0 AS final

COPY --from=builder /public /public

USER nonroot:nonroot

# The port that the application listens on.
EXPOSE 8000 8001
ENTRYPOINT ["/dashboard-web", "--insecure-bind-address=0.0.0.0", "--bind-address=0.0.0.0"]