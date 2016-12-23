#include <stdlib.h>

// [[Rcpp::export(".exec")]]
int exec(const char* file) {
  system(file);
  return 0;
}
