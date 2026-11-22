package db

import (
	"bytes"
	"slices"
	"testing"
	"testing/iotest"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestEntryEncode checks the 0102 record format in both directions.
func TestEntryEncode(t *testing.T) {
	ent := Entry{key: []byte("k1"), val: []byte("xxx")}
	data := []byte{2, 0, 0, 0, 3, 0, 0, 0, 'k', '1', 'x', 'x', 'x'}

	assert.Equal(t, data, ent.Encode())

	decoded := Entry{}
	err := decoded.Decode(bytes.NewBuffer(data))
	assert.Nil(t, err)
	assert.Equal(t, ent, decoded)
}

// QzBQWVJJOUhU https://trialofcode.org/

// TestEntryRecordFormat checks Encode and Decode against independent fixtures.
func TestEntryRecordFormat(t *testing.T) {
	// Testing strategy
	//
	// cover the cartesian product of these partitions:
	//   partition on key: empty, nonempty
	//   partition on value: empty, nonempty
	//
	// cover the subdomains of these partitions:
	//   partition on lengths when both fields are nonempty:
	//     key shorter than value, equal lengths, key longer than value
	//   partition on key length: 0, 1..255, 256 or more
	//   partition on value length: 0, 1..255, 256 or more
	//
	// The 255- and 256-byte cases exercise both sides of the point where
	// the second little-endian length byte first becomes nonzero.

	cases := []struct {
		name       string
		key        []byte
		value      []byte
		wantHeader [8]byte
	}{
		{
			name:       "covers empty key and empty value",
			wantHeader: [8]byte{},
		},
		{
			name:       "covers empty key and nonempty value",
			value:      []byte("v"),
			wantHeader: [8]byte{0, 0, 0, 0, 1, 0, 0, 0},
		},
		{
			name:       "covers nonempty key and empty value",
			key:        []byte("k"),
			wantHeader: [8]byte{1, 0, 0, 0, 0, 0, 0, 0},
		},
		{
			name:       "covers nonempty key shorter than value",
			key:        []byte{0x00, 0xff},
			value:      []byte("val"),
			wantHeader: [8]byte{2, 0, 0, 0, 3, 0, 0, 0},
		},
		{
			name:       "covers equal nonempty lengths",
			key:        []byte("k"),
			value:      []byte("v"),
			wantHeader: [8]byte{1, 0, 0, 0, 1, 0, 0, 0},
		},
		{
			name:       "covers key longer than nonempty value",
			key:        []byte("key"),
			value:      []byte("v"),
			wantHeader: [8]byte{3, 0, 0, 0, 1, 0, 0, 0},
		},
		{
			name:       "covers key length 255 and value length 256",
			key:        bytes.Repeat([]byte{'k'}, 255),
			value:      bytes.Repeat([]byte{'v'}, 256),
			wantHeader: [8]byte{0xff, 0, 0, 0, 0, 1, 0, 0},
		},
		{
			name:       "covers key length 256 and value length 255",
			key:        bytes.Repeat([]byte{'k'}, 256),
			value:      bytes.Repeat([]byte{'v'}, 255),
			wantHeader: [8]byte{0, 1, 0, 0, 0xff, 0, 0, 0},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			wire := slices.Concat(tc.wantHeader[:], tc.key, tc.value)

			t.Run("Encode", func(t *testing.T) {
				ent := Entry{key: bytes.Clone(tc.key), val: bytes.Clone(tc.value)}
				assert.Equal(t, wire, ent.Encode())
			})

			t.Run("Decode", func(t *testing.T) {
				ent := Entry{key: []byte("previous key"), val: []byte("previous value")}
				require.NoError(t, ent.Decode(bytes.NewReader(wire)))
				assert.Equal(t, string(tc.key), string(ent.key), "decoded key bytes")
				assert.Equal(t, string(tc.value), string(ent.val), "decoded value bytes")
			})
		})
	}
}

// TestEntryDecodeShortReads covers a complete record delivered one byte at a time.
func TestEntryDecodeShortReads(t *testing.T) {
	wire := []byte{2, 0, 0, 0, 2, 0, 0, 0, 'k', '1', 'v', '2'}
	reader := iotest.OneByteReader(bytes.NewReader(wire))

	var ent Entry
	require.NoError(t, ent.Decode(reader))
	assert.Equal(t, []byte("k1"), ent.key)
	assert.Equal(t, []byte("v2"), ent.val)
}

// TestEntryEncodeIndependentBytes checks that editing the result preserves the entry.
func TestEntryEncodeIndependentBytes(t *testing.T) {
	ent := Entry{key: []byte("k"), val: []byte("v")}
	want := []byte{1, 0, 0, 0, 1, 0, 0, 0, 'k', 'v'}

	encoded := ent.Encode()
	require.Equal(t, want, encoded)
	encoded[8], encoded[9] = 'K', 'V'

	assert.Equal(t, want, ent.Encode())
}
