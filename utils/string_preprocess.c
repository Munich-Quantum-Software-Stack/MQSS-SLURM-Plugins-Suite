#include <stdio.h>
#include <string.h>

int main() {
    char input_string[] = "TresPerNode=gres/qpu:1";
    char pattern[] = "qpu";

    printf("Input String: %s\n", input_string);
    printf("Pattern: %s\n", pattern);
    
    int result = strstr(input_string, pattern) != NULL;
    printf("Pattern found: %s\n", result ? "Yes" : "No");

    return 0;
}