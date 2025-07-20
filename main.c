int main() {
    // types and variables
    int myVariable = 10;
    float myFloat = 3.14;
    char myChar = 'A';
    double myDouble = 2.71828;
    // string myString = "Hello, World!";
    char myString[] = "Hello, World!";
    // bool myBool = true;
    int isTrue = 1; // Using int for boolean representation

    // data structures
    // array
    int myArray[5] = {1, 2, 3, 4, 5};

    // print the first element of the array
             //  0 1 2 3 4
    // myArray: [1,2,3,4,5]
    printf("First element of myArray: %d\n", myArray[0]);


    // conditionals
    if (myVariable > 5) {
        printf("myVariable is greater than 5\n");
    } else if (myVariable == 5) {
        printf("myVariable is equal to 5\n");
    } else {
        printf("myVariable is not greater than 5\n");
    }

    // operators
    // arithmetic: + - * /
    // comparison: == != < > <= >=
    // logical: && || !
    if (!(myVariable > 5) && myFloat < 4.0) {
        printf("myVariable is greater than 5 and myFloat is less than 4.0\n");
    } else {
        printf("Condition not met\n");
    }


    // loops
    int j = 0;
    while (j < 5) {
        printf("Element at index %d: %d\n", j, myArray[j]);
        j++;
    }

    for (int i = 0; i < 5; i++) {
        printf("Element at index %d: %d\n", i, myArray[i]);
    }

    char command = 'y';
    while (command != 'n') {
        printf("Enter 'n' to stop the loop, or any other key to continue: ");
        scanf(" %c", &command);
        if (command != 'n') {
            printf("You entered: %c\n", command);
        }
    }

    
    // functions
    void myFunction() {
        printf("This is a simple function.\n");
        for (int i = 0; i < 3; i++) {
            printf("Function iteration %d\n", i);
        }
    }
    myFunction();
    myFunction(); // Calling the function again

    int mySum(int a, int b) {
        return a + b;
    }
    // mySum(5, 10);
    int result = mySum(5, 10);


    // 
}