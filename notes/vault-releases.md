# Vault-Releases 

A web-based cold storage interface for vault operations, built with a Rust (`axum`) backend and vanilla JavaScript frontend. This implementation is a drop-in replacement to the previous `vault-cold-bridge` project.
The backend consists of a set of endpoints that are exposed by cold-bridge externally, as well as internal endpoints that mock the usual communication between vault-bridge and the harmonize gateways, as to allow for vault 
operations to be dispatched and processed by the vault-stack. All endpoints can perceive a mutual state that is defined by the `AppState` struct and maps almost directly to all of vault-cold's features. [LLD](https://metaco.atlassian.net/wiki/spaces/Arch/pages/edit-v2/1609334802?draftShareId=83d551d6-87ad-4238-85ad-a3c936c42890) can be consulted for further details.

- `POST /v1/feed/upload` - File upload endpoint
- `GET /v1/feed/download` - File download endpoint  
- `GET /v1/feed/status` - Application status displaying currently ongoing operations
- `GET /v1/feed/decode` - Decoded file download of uploaded payload
- `GET /v1/feed/events` - Backend events log

By default served at `http://localhost:8080`.

### To-Do: 
- [X] Format stage
- [X] Clippy stage
- [X] Build stage
    - [ ] Issue HTTPS certificate
    - [ ] Enable HTTPS needed secrets for build
- [ ] Backup MPC
    - [X] Implement cold-bridge end functionality
    - [ ] Finish [core-extensions](https://gitlab.com/ripple/custody/platform/core/core-extensions/-/merge_requests/337) end functionality

### Review
Things I am most unsure about:
- Pipeline stage and job definitions
    - [.gitlab-ci.yml](https://gitlab.com/ripple/custody/platform/core/vault/-/blob/feature/PROV-576.Cold.Bridge.Migration/.gitlab-ci.yml)
- HTTPs workflow
    - [resources/docker/Dockerfile](https://gitlab.com/ripple/custody/platform/core/vault/-/blob/feature/PROV-576.Cold.Bridge.Migration/resources/docker/Dockerfile)
    - [src/service.rs](https://gitlab.com/ripple/custody/platform/core/vault/-/blob/feature/PROV-576.Cold.Bridge.Migration/src/service.rs)

### Tickets
- PROV-576
- [IS-17689](https://ripplelabs.atlassian.net/browse/IS-17689?focusedCommentId=784659&sourceType=mention)
- [MR-337](https://gitlab.com/ripple/custody/platform/core/core-extensions/-/merge_requests/337)
