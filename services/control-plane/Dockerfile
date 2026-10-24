# Control-plane image (DESIGN.md §9.3, ADR-022, §15 D86): a static binary on distroless, non-root.
# Build from services/control-plane: docker build -t control-plane .
FROM golang:1.27.3-bookworm@sha256:972b4110ba0f47539a975c31e52c64765e1ff19f2d74469ae4a595c6676e80a5 AS build
WORKDIR /src
ENV CGO_ENABLED=0 GOWORK=off GOTOOLCHAIN=local GOFLAGS=-trimpath
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN go build -ldflags='-s -w -buildid=' -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab
COPY --from=build /out/api /api
USER nonroot:nonroot
ENTRYPOINT ["/api"]
CMD ["serve"]
