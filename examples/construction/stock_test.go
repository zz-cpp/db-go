package construction

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// Testing strategy for Stock.Take:
//
// Domain: n > 0 and remaining >= 0 before the call.
// Partition on availability:
//   - E: remaining == 0.
//   - L: 0 < n < remaining.
//   - B: n == remaining.
//   - S: 0 < remaining < n.
//
// Boundaries: n == remaining and n == remaining + 1 for positive stock.
func TestStockTake(t *testing.T) {
	cases := []struct {
		name          string
		initial       int
		requested     int
		wantOK        bool
		wantRemaining int
	}{
		{name: "E_empty_stock", initial: 0, requested: 1, wantOK: false, wantRemaining: 0},
		{name: "L_smaller_request", initial: 2, requested: 1, wantOK: true, wantRemaining: 1},
		{name: "B_exact_stock", initial: 2, requested: 2, wantOK: true, wantRemaining: 0},
		{name: "S_one_above_stock", initial: 2, requested: 3, wantOK: false, wantRemaining: 2},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			stock := NewStock(tc.initial)
			if got := stock.Remaining(); got != tc.initial {
				t.Fatalf("initial stock = %d, want %d", got, tc.initial)
			}

			ok := stock.Take(tc.requested)

			assert.Equal(t, tc.wantOK, ok, "withdrawal result")
			assert.Equal(t, tc.wantRemaining, stock.Remaining(), "stock after withdrawal")
		})
	}
}

func TestStockZeroValue(t *testing.T) {
	var stock Stock
	assert.Equal(t, 0, stock.Remaining())
	assert.False(t, stock.Take(1))
	assert.Equal(t, 0, stock.Remaining())
}
