void main() {
    int dividend[] = {68, 100, 43, 22, 63, 63, 6, 44, 31, 2};
    int divisor[] = {70, 13, 10, 99, 85, 17, 91, 10, 39, 78};
    int quotient[10];
    int remainder[10];
    for (int i = 0; i < 10; i++) {
        quotient[i] = dividend[i] / divisor[i];
        remainder[i] = dividend[i] % divisor[i];
    }
}