from numba import cuda
import numpy as np
import time
import math
# CUDA kernel
@cuda.jit
def conjecture_kernel(step, counting_step, progress, limit):
    num_threads=progress[0]
    idx = cuda.grid(1)
    if idx >= num_threads:
        return
    
    number = np.int64(1 + idx * 2)  # Ensure number is of type np.int64
    next_checkpoint = np.int64(counting_step)
    loops = (limit//num_threads)//2
    
    if idx == 0:
        for _ in range(loops):
            # print(number)
            curr = np.int64(number * 3 + 1)  # Ensure curr is np.int64
            if number > next_checkpoint and next_checkpoint > 0:
                val = (number/counting_step)/10
                print("Thread", idx, "has reached",val, "Quintillion")
                next_checkpoint += counting_step
            while curr > number:
                if curr % 2 == 1:
                    curr = np.int64(curr * 3 + 1)  # Ensure curr is np.int64
                else:
                    curr //= 2

            number += step
    else:
        for _ in range(loops):
            # print(number)
            curr = np.int64(number * 3 + 1)  # Ensure curr is np.int64
            while curr > number:
                if curr % 2 == 1:
                    curr = np.int64(curr * 3 + 1)  # Ensure curr is np.int64
                else:
                    curr //= 2

            number += step
    # progress[idx] = number

    



def format_number(n):
    suffixes = ['','K','M','B','T','Q','QN']
    i = 0
    f = float(n)
    while f >= 1000 and i < len(suffixes) - 1:
        f /= 1000
        i += 1
    return f"{f:.1f}{suffixes[i]}"

# Main runner
if __name__ == "__main__":
    start = time.time()
    tb = 1024
    bg = 64_000_000
    num_threads = tb * bg

    limit = np.int64(2**63-1)
    step = np.int64(num_threads * 2)  # Ensure step is np.int64
    print_step = np.int64(100_000_000_000_000_000)  # Ensure counting_step is np.int64
    
    print("proposed limit:", format_number(limit), f"({limit})")
    resulting = int(limit)*int(step)//num_threads
    print()
    # GPU progress array
    progress = np.zeros(1, dtype=np.int64)
    progress[0] = num_threads
    d_progress = cuda.to_device(progress)

    threads_per_block = tb
    blocks_per_grid = bg  # (num_threads + threads_per_block - 1) // threads_per_block

    # Run kernel
    conjecture_kernel[blocks_per_grid, threads_per_block](step, print_step, d_progress, limit)

    # Fetch result
    d_progress.copy_to_host(progress)
    s = 0
    print("finished in ", time.time()-start)
    # print("aaaaaa")
    # for i in range(num_threads):
    #     s += progress[i] - (1_000_000*num_threads*2) - (1 + i * 2)
    #     # print(f"Thread {i} reached: {format_number(progress[i])}")
    # print(s)