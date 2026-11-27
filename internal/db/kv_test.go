package db

/*
 * Testing strategy
 *
*
*
* Get(), Del():
* 	partition on whether key in store:
* 		- key exisit in store.
* 		- key does not exisit in store.
*
* 	partition on key value:
* 		- key is nil
* 		- key length is 0
* 		- key length is more than 0
*
* Set():
* 	partition on key value:
* 		- key is nil
* 		- key length is 0
* 		- key length is more than 0
*
* Open():
* 	partition on
*
*/

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TODO: Choose a write history for one key that distinguishes replaying the
// first value from replaying the latest value. Reopen the same file with a
// fresh KV and check the expected value with Get. Record the covered case
// in the testing strategy.

func TestKVBasic(t *testing.T) {
	kv := KV{}
	kv.log.FileName = ".test_db"
	defer os.Remove(kv.log.FileName)

	os.Remove(kv.log.FileName)
	err := kv.Open()
	assert.Nil(t, err)
	defer kv.Close()

	updated, err := kv.Set([]byte("k1"), []byte("v1"))
	assert.True(t, updated && err == nil)

	val, ok, err := kv.Get([]byte("k1"))
	assert.True(t, string(val) == "v1" && ok && err == nil)

	_, ok, err = kv.Get([]byte("xxx"))
	assert.True(t, !ok && err == nil)

	updated, err = kv.Del([]byte("xxx"))
	assert.True(t, !updated && err == nil)

	updated, err = kv.Del([]byte("k1"))
	assert.True(t, updated && err == nil)

	_, ok, err = kv.Get([]byte("xxx"))
	assert.True(t, !ok && err == nil)

	updated, err = kv.Set([]byte("k2"), []byte("v2"))
	assert.True(t, updated && err == nil)

	// reopen
	kv.Close()
	err = kv.Open()
	assert.Nil(t, err)

	_, ok, err = kv.Get([]byte("k1"))
	assert.True(t, !ok && err == nil)
	val, ok, err = kv.Get([]byte("k2"))
	assert.True(t, string(val) == "v2" && ok && err == nil)
}

// QzBQWVJJOUhU https://trialofcode.org/
