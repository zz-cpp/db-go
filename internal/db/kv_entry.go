package db

import (
	"encoding/binary"
	"io"
)

const maxLength uint64 = (1 << 32) - 1

// Entry represents a mutable set or deletion record.
type Entry struct {
	// Rep invariant:
	//   len(key) and len(val) are each at most maxLength.
	// Abstraction function:
	//   AF(key, val, deleted) removes key when deleted is true and sets key
	//   to val otherwise. A nil slice represents an empty byte sequence.
	// Safety from rep exposure:
	//   The slices are unexported. Encode copies the payload into a new slice.
	//   Decode fills new slices through io.Reader, which may not retain them.
	key     []byte
	val     []byte
	deleted bool
}

// checkRep panics if the representation invariant is violated.
func (ent *Entry) checkRep() {
	if uint64(len(ent.key)) > maxLength || uint64(len(ent.val)) > maxLength {
		panic("Rep invariant failed")
	}
}

// Encode returns a fresh byte slice containing the record's binary encoding.
//
// require: The receiver must be non-nil.
//
// effects: Encode preserves the receiver's fields.
//
// The slice has length 9 + K + V. K is the key length in bytes. V is the
// value length in bytes for a set record and zero for a deletion record.
// Each range below includes its start and excludes its end.
//
//	[0, 4)          K as a little-endian uint32
//	[4, 8)          V as a little-endian uint32
//	[8, 9)          0 for a set record, 1 for a deletion record
//	[9, 9+K)        Key bytes in order
//	[9+K, 9+K+V)    Value bytes in order for a set record
func (ent *Entry) Encode() []byte {
	ent.checkRep()
	val := ent.val
	if ent.deleted {
		val = nil
	}

	data := make([]byte, 9+len(ent.key)+len(val))
	binary.LittleEndian.PutUint32(data[0:4], uint32(len(ent.key)))
	binary.LittleEndian.PutUint32(data[4:8], uint32(len(val)))
	if ent.deleted {
		data[8] = 1
	}
	copy(data[9:], ent.key)
	copy(data[9+len(ent.key):], val)
	return data
}

// Decode reads one encoded key-value record from r into the receiver.
//
// require: The receiver and r must be non-nil.
//
// effects: If r provides a complete record in the format described by
// [Entry.Encode], Decode returns nil and replaces the receiver's key,
// value, and deletion flag. The value of a deletion record is nil.
//
// If reading the record fails, Decode returns an error and preserves the
// receiver's fields. The reader may have advanced before the error.
func (ent *Entry) Decode(r io.Reader) error {
	var head [9]byte

	if _, err := io.ReadFull(r, head[:]); err != nil {
		return err
	}

	keyLen := binary.LittleEndian.Uint32(head[0:4])
	valLen := binary.LittleEndian.Uint32(head[4:8])
	deleted := head[8] != 0

	key := make([]byte, keyLen)
	val := make([]byte, valLen)

	if _, err := io.ReadFull(r, key); err != nil {
		return err
	}

	if _, err := io.ReadFull(r, val); err != nil {
		return err
	}

	if deleted {
		val = nil
	}
	ent.key = key
	ent.val = val
	ent.deleted = deleted

	ent.checkRep()

	return nil
}

// QzBQWVJJOUhU https://trialofcode.org/
