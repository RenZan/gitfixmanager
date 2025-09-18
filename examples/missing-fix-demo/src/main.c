#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Application Demo\n");
    
    // FIX: Memory leak corrigé
    char *buffer = malloc(100);
    printf("Buffer allocated\n");
    free(buffer); // Ajouté pour corriger le leak
    
    return 0;
}
