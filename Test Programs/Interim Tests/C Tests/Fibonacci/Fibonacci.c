int main() {
    int nums[100];
    nums[0] = 0;
    nums[1] = 1;
    for (int i = 2; i < 100; i++) {
        nums[i] = nums[i - 1] + nums[i - 2];
    }
}