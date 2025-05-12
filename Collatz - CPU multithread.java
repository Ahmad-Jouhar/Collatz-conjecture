import java.text.DecimalFormat;

public class Conjecture {
    public static void main(String[] args) {
        // You can pass a number when creating the thread
        int numthreads = 24;  // Example input
        for (int i = 0; i < numthreads; i++){
            // System.out.println("yeet");
            Thread thread = new Thread(new MyRunnable(1+i*2, numthreads*2));  // Pass number to the thread
            thread.start();  // Start the thread    
        }
    }
}

class MyRunnable implements Runnable {
    private long number;  // Instance variable to hold the number
    private long step;  // Instance variable to hold the number
    private long countingStep = 1000;
    private int threadNum;

    // Constructor that accepts a number
    public MyRunnable(long number, int step) {
        this.number = number;
        this.step = step;
        this.threadNum = (((int)number)-1)/2;
        countingStep*=countingStep*countingStep*100; // countingStep is now 100B
    }

    @Override
    public void run() {
        // Print the number that was passed as input
        System.out.println(number);
        long curr;
        long next = 0;
        while (true) {
            curr = number*3 + 1;
            if (curr == number) {
                System.out.println(curr + " is the number!");
            }
            if (number > next){
                next += countingStep;
                System.out.println("Thread " + threadNum + " has reached: " + formatNumber(number));
            }
            while (curr > number){
                // System.out.println("Thread " + threadNum + " has reached: " + formatNumber(number));
                if (curr % 2 == 1) {
                    curr = curr*3 + 1;
                } else {
                    curr/=2;
                }
            }
            number+=step;
        }
    }

    public static String formatNumber(long number) {
        // Define suffixes for the orders of magnitude
        String[] suffixes = {"", "K", "M", "B", "T"};
        int i = 0;
    
        // Loop to find the appropriate suffix based on the magnitude of the number
        double formattedNumber = number;
        while (formattedNumber >= 1000 && i < suffixes.length - 1) {
            formattedNumber /= 1000;
            i++;
        }
    
        // Return the formatted number with 1 decimal place, followed by the suffix
        DecimalFormat df = new DecimalFormat("#.#");
        return df.format(formattedNumber) + suffixes[i];
    }
    
}
