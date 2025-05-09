void main() {
    int fib[100];
    fib[0] = 0;
    fib[1] = 1;
    for (int i = 0; i < 98; i++) {
        fib[i] = fib[i-1] + fib[i-2];
    }
}