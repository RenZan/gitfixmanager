#include <stdio.h>
#include <string.h>

int parse_input(char *input) {
    // BUG: Pas de vérification de input avant strlen
    return strlen(input); // Crash si input est NULL
}
