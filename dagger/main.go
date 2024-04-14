// A generated module for Pipeline functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
)

type Pipeline struct{}

func (p *Pipeline) Build(ctx context.Context) (string, error) {
	// checkout dagger repo
	proj := dag.Git("https://github.com/dagger/dagger", GitOpts{KeepGitDir: true}).
		Branch("main").
		Tree()
		// use golang:latest as container and create a witness config
	builder := dag.Container().From("golang:latest").
		WithDirectory("/src", proj).
		WithWorkdir("/src").
		With(CreateWitnessConfig)

	// Without Witness
	// build = builder.
	//	WithExec([]string{"go", "test", "./..."}).
	//	WithExec([]string{"go", "build", "./cmd/dagger"}).
	// 	File("./dagger")

	// With Witness
	witnessBuild := dag.Witness().
		WitnessRun(
			[]string{"go", "build", "./cmd/dagger"},
			builder) // pass builder container to the Witness module

	// witness.json could also be stored in archivista
	witnessOut := witnessBuild.Collect() // get the witness.json
	//buildBinary := witnessBuild.Base.File("./dagger")

	return witnessOut.Contents(ctx)
}

func CreateWitnessConfig(ctr *Container) *Container {
	yaml := `
run:
    signer-file-key-path: testkey.pem
    trace: false
`

	return ctr.
		WithNewFile(".witness.yaml", ContainerWithNewFileOpts{Contents: yaml}).
		WithExec([]string{"sh", "-c", "openssl genpkey -algorithm ed25519 -outform PEM -out testkey.pem"}).
		WithExec([]string{"sh", "-c", "openssl pkey -in testkey.pem -pubout > testpub.pem"})
}
