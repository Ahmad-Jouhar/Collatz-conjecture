# reached number: 76117090

#starter values
num1 = 76117090
num2 = num1

while True:      
    if int(num2) == 1:
        num1 += 1
        num2 = num1
        print(num1)

    while num2 != 1:

        #if odd then 3x +1
        if (num2 % 2) == 1:
            num2 = (num2 * 3) + 1

        #if even then /2
        else:
            num2 = num2 // 2