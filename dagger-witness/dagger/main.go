// A generated module for Witness functions
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
	"fmt"
	"runtime"
)

type Witness struct{}

// Create base witness container
func (w *Witness) Base(
	// +optional
	// +default="ghcr.io/in-toto/witness:0.3.1"
	witnessImg string,
) *Container {
	return dag.Container().From(witnessImg).
		WithMountedFile("/bin/witness", getWitnessBinary())
}

// Execute and Witness a command
func (w *Witness) Run(
	cmdArgs []string,
	// +optional
	// +default="ghcr.io/in-toto/witness:0.3.1"
	witnessImg string,
) *Container {
	witness := []string{"/bin/witness", "run", "-o", "/witness.json", "--step", "foo", "--"} // probably need this to be more configurable
	cmd := append(witness, cmdArgs...)
	return w.Base(witnessImg).WithExec(cmd)
}

// Execute and Witness a command
func (w *Witness) Verify(
	cmdArgs []string,
	// +optional
	// +default="ghcr.io/in-toto/witness:0.3.1"
	witnessImg string,
) *File {
	witness := []string{"/bin/witness", "verify", "-r", "/root.json"} // probably need this to be more configurable
	cmd := append(witness, cmdArgs...)
	return w.Base(witnessImg).WithExec(cmd).
		File("/witness.json")
}

// Download Witness binary
func getWitnessBinary() *File {
	// Download binary
	version := "0.2.0" // should be a parameter
	arch := runtime.GOARCH
	tarball := fmt.Sprintf("https://github.com/testifysec/witness/releases/download/v%s/witness_%s_linux_%s.tar.gz", version, version, arch)

	// Return as Dagger *File
	return dag.Container().From("alpine").
		WithFile("/witness.tar.gz", dag.HTTP(tarball)).
		WithExec([]string{"tar", "xvf", "/witness.tar.gz"}).
		File("/witness")
}
