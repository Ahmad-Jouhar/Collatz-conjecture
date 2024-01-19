#include <stdio.h>
#include <cs50.h>
#include <math.h>
#include <stdbool.h>

int loop(void)
{
    long i = 70928710983; // reached number
    long j = i;
    while(true)
    {
        j = j + 2; // we are skipping even numbers since they were tested from previous odd numbers
        i = j;
        while(i >= j) // if the number becomes less thant it originally was, we are testing a previously tested number
        {
            if(i % 2 == 0)
            {
                i = (i/2); 
            }
            else
            {
                i = (3 * i) + 1;
            }
        }
        printf("%li \n", j);
    }
}

int main(void)
{
    loop();
}