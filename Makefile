.PHONY: all
all: test docker-build scan-image ## Run all targets.

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...
	echo "Completed go fmt."

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...
	echo "Completed go vet."

.PHONY: lint
lint: ## Run hadolint against Dockerfile.
	/bin/sh -c "hadolint -f sarif Dockerfile > release/evidence/hadolint.sarif"
	echo "Completed scan for non-root software with hadolint."

.PHONY: sast
sast: ## Scan code with Semgrep.
	semgrep scan --config auto ./ --sarif -o release/evidence/semgrep.sarif
	echo "Completed static analysis with Semgrep."

.PHONY: test
test: ## Run tests.
	go test ./... -coverprofile release/evidence/cover.out
	echo "Completed unit tests."

.PHONY: build
build: ## Local go build.
	go build -o bin/software main.go

.PHONY: docker-build
docker-build: ## Build docker image.
	/bin/sh -c "docker build -t jkjell/software:dev . && docker save jkjell/software:dev > release/delivery/image.tar"
	echo "Completed docker build."

.PHONY: scan-image
scan-image: generate-sbom cve-scan secret-scan ## Scan image.

.PHONY: generate-sbom
generate-sbom: ## Generate SBOM with Syft.
	syft packages docker-archive:./release/delivery/image.tar -o spdx-json --file release/evidence/syft.spdx.json
	echo "Completed generating SBOM with Syft."

.PHONY: cve-scan
cve-scan: ## Scan image for CVEs with Grype.
	grype docker-archive:./release/delivery/image.tar -o sarif --file release/evidence/grype.sarif 
	echo "Completed cve scan with Grype."

.PHONY: secret-scan
secret-scan: ## Scan image for secrets with Trufflehog.
	/bin/sh -c "trufflehog docker --image=file://release/delivery/image.tar -j > release/evidence/trufflehog.json"
	echo "Completed secret scan with Trufflehog."

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

