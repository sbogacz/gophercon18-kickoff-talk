package store

import "context"

// Store provides an interface to the blobs we
// store in the toy app
type Store interface {
	Get(context.Context, string) (string, error)
	Set(context.Context, string, string) (string, error)
	Del(context.Context, string) error
}
