package db

import (
	"encoding/binary"
	"io"
)

const maxLength uint64 = (1 << 32) - 1

// Entry represents a mutable key-value record.
type Entry struct {
	// Rep invariant:
	//   len(key) and len(val) are each at most maxLength.
	// Abstraction function:
	//   AF(key, val) is the record that associates the bytes in key with
	//   the bytes in val. A nil slice represents an empty byte sequence.
	// Safety from rep exposure:
	//   Both fields are unexported. Encode copies their bytes into a new slice.
	//   Decode fills new slices through io.Reader, which may not retain them.
	key []byte
	val []byte
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
// effects: Encode preserves the receiver's key and value.
//
// The slice has length 8 + K + V, where K and V are the key and value lengths
// in bytes. Each range below includes its start and excludes its end.
//
//	[0, 4)          K as a little-endian uint32
//	[4, 8)          V as a little-endian uint32
//	[8, 8+K)        Key bytes in order
//	[8+K, 8+K+V)    Value bytes in order
func (ent *Entry) Encode() []byte {
	ent.checkRep()
	data := make([]byte, 4+4+len(ent.key)+len(ent.val))
	binary.LittleEndian.PutUint32(data[0:4], uint32(len(ent.key)))
	binary.LittleEndian.PutUint32(data[4:8], uint32(len(ent.val)))
	copy(data[8:], ent.key)
	copy(data[8+len(ent.key):], ent.val)
	return data
}

// Decode reads one encoded key-value record from r into the receiver.
//
// require: The receiver and r must be non-nil.
//
// effects: If r provides a complete record in the format described by
// [Entry.Encode], Decode returns nil and sets the key and value to the
// corresponding bytes.
//
// If reading the record fails, Decode returns an error and preserves the
// receiver's previous key and value. The reader may have advanced before
// the error.
func (ent *Entry) Decode(r io.Reader) error {
	head := make([]byte, 8)

	if _, err := io.ReadFull(r, head); err != nil {
		return err
	}

	keyLen := binary.LittleEndian.Uint32(head[0:4])
	valLen := binary.LittleEndian.Uint32(head[4:8])

	key := make([]byte, keyLen)
	val := make([]byte, valLen)

	if _, err := io.ReadFull(r, key); err != nil {
		return err
	}

	if _, err := io.ReadFull(r, val); err != nil {
		return err
	}

	ent.key = key
	ent.val = val

	ent.checkRep()

	return nil
}
