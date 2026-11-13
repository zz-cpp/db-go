package db

import (
	"bytes"
	"errors"
)

// KV is a mutable in-memory key-value store.
//
//	Abstraction function:
//		AF(mem) = { k -> mem[k] | all k in mem }
//
// TODO(user): state the abstract domain, how string keys map to byte keys,
// and what the empty map denotes.
//
//	Rep invariant:
//		len( each of mem.keys) >= 1
//		len( each of mem.values) >= 1
//
// TODO(user): rewrite the two lines above as decidable predicates; decide
// whether empty keys and values are legal; add mem != nil or an Open
// precondition if the zero value is not usable.
//
//	Safety from rep exposure:
//			mem is private
//			mem.val is mutable, So Get() and Set() make defensive copies to avoid sharing the rep's values in mem with clients
//
// TODO(user): separate inbound and outbound copying; explain why key needs no
// copy; state what Get returns when the key is absent.
type KV struct {
	mem map[string][]byte
}

var ErrKeyIsNil = errors.New("key is nil")

// ErrNotFound      = errors.New("key not found")
// ErrUpdatedFailed = errors.New("updated val not found")

// func (kv *KV) checkRI() {
// 	// TODO(user): implement the RI checks, or remove this function if the
// 	// invariant is maintained by construction.
// }

// Open initializes the KV store.
//
// TODO(user): state whether KV must be opened before use.
// TODO(user): state the effect of calling Open more than once.
// TODO(user): state when Open returns a non-nil error.
func (kv *KV) Open() error {
	kv.mem = map[string][]byte{} // empty
	return nil
}

// Close closes the KV store.
//
// TODO(user): state whether the store remains usable after Close.
// TODO(user): state whether Close is idempotent.
// TODO(user): state when Close returns a non-nil error.
func (kv *KV) Close() error { return nil }

// Get returns the new value associated with key.
//
// Parameters:
//
//   - key: the key to look up.
//
// Preconditions:
//
//   - nothing.
//
// Postconditions:
//
// If key exists in the store:
//
//   - val is a clone of the value associated with the key.
//   - ok is thrue.
//   - err is nil.
//
// If key does not in the store:
//
//   - val is nil.
//   - ok is false.
//   - err is nil.
//
// If key is nil:
//
//   - val is nil.
//   - ok is false.
//   - err is a obj represents the reasons of error occuring.
func (kv *KV) Get(key []byte) (val []byte, ok bool, err error) {
	val, ok = kv.mem[string(key)]
	val = bytes.Clone(val)

	return
}

// Set stores val under key.
//
// Parameters:
//
//   - key: the key to be seted in store.
//   - val: the value associated with the key  to be setted in store.
//
// Preconditions:
//
//   - noting.
//
// Postconditions:
//
// the key and val will be a stored unique pair.
//
// If len(key)>=1:
//
//   - updated is true.
//   - err is nil.
//
// If len(key) is 0, but != nil:
//
//   - updated is false.
//   - err is nil.
//
// If key == nil:
//
//   - updated is false.
//   - err is obj represents the key is nil.
func (kv *KV) Set(key []byte, val []byte) (updated bool, err error) {
	if key == nil {
		return false, ErrKeyIsNil
	} else if len(key) == 0 {
		return false, nil
	}

	kv.mem[string(key)] = bytes.Clone(val)
	newVal, _ := kv.mem[string(key)]
	updated = bytes.Equal(val, newVal)
	return
}

// Del removes key.
//
// Parameters:
//
//   - key: the key to look up
//
// Preconditions:
//
//   - nothing.
//
// Postconditions:
//
// If the key is in store:
//
//   - deleted = true.
//   - err = nil.
//
// If the key is not in store:
//
//   - deleted = false.
//   - err = nil.
//
// If the key == nil:
//
//   - deleted = false.
//   - err is a obj represents the key is nil.
//
// Side Effects:
//
// the key and its val will be removed from memory.
func (kv *KV) Del(key []byte) (deleted bool, err error) {
	if key == nil {
		return false, ErrKeyIsNil
	}
	_, deleted = kv.mem[string(key)]

	if deleted {
		delete(kv.mem, string(key))
	}
	return
}
