
int gcd(int a, int b) {
    if (a == 0)
        return b;
    if (b == 0)
        return a;
    
    if (a == b)
        return a;

    if (a > b)
        return gcd(a - b, b);
    return gcd(a, b - a);
}


void main() {
    int a[] = {44, 73, 10, 71, 6, 52, 81, 26, 43, 7};
    int b[] = {79, 40, 6, 15, 14, 91, 12, 31, 91, 42};
    int c[10];
    for (int i = 0; i < 10; i++)
        c[i] = gcd(a[i], b[i]);
}