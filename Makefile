WITNESS_RUN = witness run -s $@ -k ../vault/swfkey.pem -o release/attestations/$@.att.json --

.PHONY: all
all: test docker-build scan-image ## Run all targets.

.PHONY: fmt
fmt: ## Run go fmt against code.
	$(WITNESS_RUN) go fmt ./...
	read -p "Completed go fmt."

.PHONY: vet
vet: ## Run go vet against code.
	$(WITNESS_RUN) go vet ./...
	read -p "Completed go vet."

.PHONY: lint
lint: ## Run hadolint against Dockerfile.
	$(WITNESS_RUN) /bin/sh -c "hadolint -f sarif Dockerfile > release/evidence/hadolint.sarif"
	read -p "Completed scan for non-root software with hadolint."

.PHONY: sast
sast: ## Scan code with Semgrep.
	$(WITNESS_RUN) semgrep scan --config auto ./ --sarif -o release/evidence/semgrep.sarif
	read -p "Completed static analysis with Semgrep."

.PHONY: test
test: lint fmt vet sast ## Run tests.
	$(WITNESS_RUN) go test ./... -coverprofile release/evidence/cover.out
	read -p "Completed unit tests."

.PHONY: build
build: test ## Local go build.
	$(WITNESS_RUN) go build -o bin/software main.go

.PHONY: docker-build
docker-build: ## Build docker image.
	$(WITNESS_RUN) /bin/sh -c "docker build -t jkjell/software:dev . && docker save jkjell/software:dev > release/delivery/image.tar"
	read -p "Completed docker build."

.PHONY: scan-image
scan-image: generate-sbom cve-scan secret-scan ## Scan image.

.PHONY: generate-sbom
generate-sbom: ## Generate SBOM with Syft.
	$(WITNESS_RUN) syft packages docker-archive:./release/delivery/image.tar -o spdx-json --file release/evidence/syft.spdx.json
	read -p "Completed generating SBOM with Syft."

.PHONY: cve-scan
cve-scan: ## Scan image for CVEs with Grype.
	$(WITNESS_RUN) grype docker-archive:./release/delivery/image.tar -o sarif --file release/evidence/grype.sarif 
	read -p "Completed cve scan with Grype."

.PHONY: secret-scan
secret-scan: ## Scan image for secrets with Trufflehog.
	$(WITNESS_RUN) /bin/sh -c "trufflehog docker --image=file://release/delivery/image.tar -j > release/evidence/trufflehog.json"
	read -p "Completed secret scan with Trufflehog."

.PHONY: release
release: ## Create a release.
	tar -czvf release.tar.gz release

.PHONY: clean
clean: ## Remove generated files.
	rm -rf bin
	rm -rf release/evidence/*
	rm -rf release/attestations/*
	rm -rf release/delivery/*
	rm release.tar.gz

