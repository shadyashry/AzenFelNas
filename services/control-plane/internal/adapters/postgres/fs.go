package postgres

import "io/fs"

// mustSub returns the embedded sub-directory; the path is a compile-time
// constant of this package, so failure is a programming error.
func mustSub(f fs.FS, dir string) fs.FS {
	sub, err := fs.Sub(f, dir)
	if err != nil {
		panic(err)
	}
	return sub
}
