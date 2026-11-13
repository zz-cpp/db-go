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
*
*/

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestKVBasic(t *testing.T) {
	kv := KV{}
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
}

// QzBQWVJJOUhU https://trialofcode.org/
