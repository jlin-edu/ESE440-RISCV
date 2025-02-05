int main() {
    int M1[2][2];
    int M2[2][2];
    int M3[2][2];

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            M1[i][j] = 1 + i + j;
            M2[i][j] = 3 - i + j;
        }
    }

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            M3[i][j] = M1[i][0] * M2[0][j] + M1[i][1] * M2[1][j];
        }
    }
}