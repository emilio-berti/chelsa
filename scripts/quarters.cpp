#include <Rcpp.h>
// [[Rcpp::export]]
NumericMatrix lowest_quarter ( NumericMatrix x ) {
  int rows = x.nrow();
  int cols = x.ncol();
  double * val;
  double * window
  NumericMatrix ans(rows, 1); //return matrix

  for (int i = 0 ; i < rows ; i++) {
    for (int j = 0 ; j < (cols - 2) ; j++) {
      *window = x(i, j) + x(i, j + 1) + x(i, j + 2)
      if (*window < *val) {
        *val = *window
      }
    }
    ans(i, 1) = *val
  }
  return ans;
}
