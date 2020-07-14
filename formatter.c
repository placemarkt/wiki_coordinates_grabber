#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

bool isCardinalDirection(char* p) {
  if (*p == 'N' || *p == 'S' || *p == 'E' || *p == 'W') {
    return true;
  } else {
    return false;
  }
}

void remove_spaces(char* s) {
    const char* d = s;
    do {
        while (*d == ' ') {
            ++d;
        }
    } while ((*(s++) = *(d++)));
}

int main(int argc, char *argv[]) {
  remove_spaces(argv[1]);
  char *p = (strstr(argv[1], "oord|") + 5);
  char coords[256];
  unsigned coordsCounter = 0;
  unsigned delimiterCounter = 0;

  while (*p) {
    if (*p == '|') {
      delimiterCounter++;
    } else if (isalpha(*p) && !isCardinalDirection(p)) {
      // break from loop if we move past coordinate
      break;
    }
    p++;
  }

  p = (strstr(argv[1], "oord|") + 5);

  if (delimiterCounter > 2) {
    // loop for cardinal direction formatted coordinates
    while (*p) {
      if (isdigit(*p)) {
        // grab number
        coords[coordsCounter] = *p;
        coordsCounter++;
      } else if (*p == '.') {
        // grab decimal points
        coords[coordsCounter] = '.';
        coordsCounter++;
      } else if (*p == '-') {
        // grab negative sign
        coords[coordsCounter] = '-';
        coordsCounter++;
      } else if (*p == '|' && (isalpha(*(p+1)) || *(p+1) == '-') && (isCardinalDirection(p+1))) {
        // add directional coordinate and space
        coords[coordsCounter] = *(p+1);
        coordsCounter++;
        coords[coordsCounter] = ' ';
        coordsCounter++;
        p++;
      } else if (*p == '|' && (isdigit(*(p+1)))) {
        // add degree delimiter
        if ((isCardinalDirection(p-1))) {
          p++;
          continue;
        } else {
          coords[coordsCounter] = ':';
          coordsCounter++;
        }
      } else if (*p == '|' && (isalpha(*(p+1)) && !isCardinalDirection(p+1))) {
        p++;
        continue;
      } else if (isalpha(*(p+1)) && !isCardinalDirection(p+1)) {
        // break from loop if we move past coordinate
        break;
      }

      p++;
    }
  } else {
    while (*p) {
      if (isdigit(*p)) {
        // grab number
        coords[coordsCounter] = *p;
        coordsCounter++;
      } else if (*p == '.') {
        // grab decimal points
        coords[coordsCounter] = '.';
        coordsCounter++;
      } else if (*p == '-') {
        // grab negative sign
        coords[coordsCounter] = '-';
        coordsCounter++;
      } else if (*p == '|' && (isdigit(*(p+1)) || *(p+1) == '-')) {
        // add space
        coords[coordsCounter] = ' ';
        coordsCounter++;
      } else if (isalpha(*(p+1))) {
        break;
      }
      p++;
    }
  }

  coords[coordsCounter] =  '\0';
  printf("%s\n", coords);
}
