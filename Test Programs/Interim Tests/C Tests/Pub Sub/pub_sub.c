#define MAX_SIZE 100

void push(int *stack, int *top, int x) {
    stack[++*top] = x;
}

int pop(int *stack, int *top) {
    return stack[*top--];
}

void producer(int *stack, int *top, int count) {
    push(stack, top, count);
}

void consumer(int *stack, int *top) {
    pop(stack, top);
}

int main() {
    int stack[MAX_SIZE];
    int top = -1;

    for (int i = 0; i < 1000; i++) {
        producer(stack, &top, i);
        consumer(stack, &top);
    }

    return 0;
}