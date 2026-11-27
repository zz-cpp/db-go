package db

import (
	"bytes"
	"errors"
)

var (
	ErrKeyIsNil   = errors.New("key is nil")
	ErrKeyIsEmpty = errors.New("key is empty")
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
//
//	Safety from rep exposure:
//			mem is private
//			mem.val is mutable, So Get() and Set() make defensive copies to avoid sharing the rep's values in mem with clients
type KV struct {
	log Log
	mem map[string][]byte
}

// Open initializes the in-memory KV store.
//
// require: kv must be non-nil. A zero-value KV is valid.
//
// effects: Open clears any existing entries, using log file to recover  data.
func (kv *KV) Open() error {
	var err error
	kv.mem = map[string][]byte{} // empty
	if err = kv.log.Open(); err != nil {
		return err
	}

	ent := Entry{}
	// debug
	replayed := 0

	// replay according to the WAL log file.
	for {
		eof, err := kv.log.Read(&ent)
		if err != nil {
			return err
		}

		if eof {
			break
		}

		if !ent.deleted {
			kv.mem[string(ent.key)] = ent.val
		} else {
			delete(kv.mem, string(ent.key))
		}

		replayed++

	}

	return err
}

// Close closes the KV store.
func (kv *KV) Close() error { return kv.log.Close() }

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

// Set stores val under key. If the key is already in store, it will modify the val. the args will not be modified.
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
// If len(key)>=1
//
//   - updated is true.
//   - err is nil.
//
//
// If len(key) is 0, but != nil:
//
//   - updated is false.
//   - err is obj represents the key length is 0.
//
// If key == nil:
//
//   - updated is false.
//   - err is obj represents the key is nil.

func (kv *KV) Set(key []byte, val []byte) (updated bool, err error) {
	if key == nil {
		return false, ErrKeyIsNil
	} else if len(key) == 0 {
		return false, ErrKeyIsEmpty
	}

	ent := Entry{key, val, false}

	if err = kv.log.Write(&ent); err != nil {
		panic("log write failed")
		// return false, err
	}

	kv.mem[string(key)] = bytes.Clone(val)

	return true, err
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
		ent := Entry{key, nil, true}

		if err = kv.log.Write(&ent); err != nil {
			panic("log write failed")
		}

		delete(kv.mem, string(key))

	}
	return
}
