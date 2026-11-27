// Package construction demonstrates a small contract and its tests.
package construction

// Stock tracks the number of units available at a supply desk.
// The zero value represents empty stock. Methods require a non-nil *Stock.
// Callers must serialize access to a shared Stock if any call can change it.
type Stock struct {
	// AF: units is the number of units available for withdrawal.
	// RI: units >= 0.
	// Safety from rep exposure: units is unexported and Remaining returns
	// an int by value. No operation gives callers access to the field itself.
	units int
}

// NewStock sets up a stock for withdrawals.
//
// Requires:
//   - initial >= 0.
//
// Effects:
//   - Returns a stock with initial units available.
func NewStock(initial int) *Stock {
	return &Stock{units: initial}
}

// Remaining returns the available units without changing the stock.
func (s *Stock) Remaining() int {
	return s.units
}

// Take handles an all-or-nothing withdrawal request.
//
// Parameters:
//   - n is the requested number of units.
//
// Requires:
//   - n > 0.
//
// Effects:
//   - If at least n units are available, returns true and reduces stock by n.
//   - Otherwise, returns false and leaves the stock unchanged.
func (s *Stock) Take(n int) bool {
	if n > s.units {
		return false
	}
	s.units -= n
	return true
}
