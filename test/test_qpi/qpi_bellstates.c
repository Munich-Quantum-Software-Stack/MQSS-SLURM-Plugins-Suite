#include "qpi.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

// ------------------------------------
// Define bellstate function
// ------------------------------------
int bell_zero(){
    QCircuit circuit;
    QClassicalRegisters MyClassicalRegisters;
    Qqubit qubitZero = 0;
    Qqubit qubitOne = 1;

    int numberOfShoots = 1024;

    qCircuitBegin(&circuit);
    qInitClassicalRegisters(&MyClassicalRegisters, 2);
    qH(qubitZero);
    qCX(qubitZero, qubitOne);
    qMeasure(qubitZero, MyClassicalRegisters, 0);
    qMeasure(qubitOne, MyClassicalRegisters, 1);
    qCircuitEnd();

    int isErr = qExecute(circuit, numberOfShoots);
    if(!isErr) {
        int *Results = qRead(circuit);
        for (int i = 0; i < 1 << qCircuitWidth(circuit); i++) {
            printf("%d %d\n", i, Results[i]);
        }
    }

    qCircuitFree(circuit);
    return 42;
}

// ------------------------------------
// Main function
// ------------------------------------
int main() {
    int err = 0;
    err = bell_zero();
    return err;
}