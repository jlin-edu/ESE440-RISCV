int factorial(int n) {
    int result = 1;
    for (int i = 1; i <= n; i++)
        result *= i;
    return result;
}

void main() {
    int n[] = {1, 9, 4, 0, 6, 2, 7, 9, 7, 7};
    int f[10];
    for (int i = 0; i < 10; i++)
        f[i] = factorial(n[i]);
}