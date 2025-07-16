# LBM-HPC: A 2D Lattice Boltzmann Method Simulation for HPC Training

This project is an experimental implementation of a 2D Lattice Boltzmann Method (LBM) simulation. Its primary goal is to serve as a training ground for parallel programming, performance optimization, and scalability analysis on High-Performance Computing (HPC) systems.

## Core Concepts

### Lattice Boltzmann Method (LBM)

The simulation is based on a **D2Q9** model (2 dimensions, 9 discrete velocities). This model describes the behavior of a fluid by tracking the distribution functions of fluid particles on a discrete lattice. Instead of solving the macroscopic Navier-Stokes equations directly, LBM simulates the movement and collision of microscopic particles.

The simulation loop consists of two main steps:
1.  **Collision:** At each lattice site, particle distribution functions are relaxed towards a local equilibrium. This step is purely local.
2.  **Streaming (Propagation):** The particle distribution functions are propagated to neighboring lattice sites according to their discrete velocities.

Boundary conditions (inflow, outflow, bounce-back for obstacles) are handled using specific methods like the Zou/He conditions.

### Parallelism Model

The code employs a hybrid parallel programming model to achieve high performance and scalability:

*   **MPI (Message Passing Interface):** Used for coarse-grained parallelism across multiple compute nodes. The simulation domain is decomposed into sub-domains (using either vertical or horizontal splits), and each MPI process is responsible for one sub-domain. Ghost cells are exchanged between neighboring processes at each time step to ensure correct calculations at the boundaries.
*   **OpenMP:** Used for fine-grained parallelism within a single compute node (shared memory). The main computation loops (collision, propagation, special cells) are parallelized using OpenMP pragmas, allowing the work to be shared among multiple CPU cores.

This hybrid approach allows the simulation to scale both *up* (using more cores on a single machine) and *out* (using more machines in a cluster).

## Building the Code

### Dependencies

*   An MPI implementation (e.g., OpenMPI, MPICH).
*   A C compiler that supports OpenMP (e.g., `gcc`).
*   `make` for building the project.

### Compilation

The project uses a `Makefile` for compilation. To build the main simulation executable (`lbm`) and a display utility, simply run:

```bash
make
```

This will compile the code using `mpicc` and produce the `lbm` executable in the root directory.

The `Makefile` allows for various compile-time configurations using C macros. For example, you can choose the domain decomposition strategy or the MPI communication pattern. See the `Makefile` for more details.

## Running the Simulation

### Configuration

The simulation is configured via a text file, passed as a command-line argument. If no file is provided, it defaults to `config.txt`.

Example configuration file:
```
# Simulation parameters
iterations = 1000
width = 512
height = 512

# Obstacle
obstacle_x = 100
obstacle_y = 256
obstacle_r = 50

# ... and more
```

### Execution

To run the simulation, use `mpirun` (or the equivalent for your MPI implementation) and specify the number of processes.

```bash
# Run on 4 MPI processes using the default config.txt
mpirun -np 4 ./lbm

# Run on 8 MPI processes with a specific configuration file
mpirun -np 8 ./lbm my_config.txt
```

The simulation will produce an output file (specified in the configuration) containing the macroscopic fluid properties (density, velocity magnitude) at specified intervals.

## Scripts and Tools

The `bash/` directory contains a variety of scripts for automation, testing, and analysis:

*   `all.sh`: Runs a comprehensive set of simulations.
*   `clean.sh`: Cleans up build artifacts and output files.
*   `debug.sh`: Runs the simulation in a debugging configuration.
*   `gen_animate_gif.sh` & `gen_single_image.sh`: Generate PNG images and animated GIFs from the raw simulation output. Require `gnuplot`.
*   `scaling.sh`: A powerful script to perform scalability studies by running the simulation with a varying number of processes/cores.
*   `validation.sh`: Runs the simulation with a reference configuration to validate the physical results.
*   **Profiling Scripts** (`maqao.sh`, `scalasca.sh`, `tau.sh`, `valgrind.sh`): Wrappers to run the simulation with various performance analysis tools.

These scripts are essential for the experimental nature of the project, allowing for systematic performance measurement and analysis.

## Performance and Optimization Journey

This project also served as an in-depth case study in HPC performance optimization. The initial code, while functional after some bug fixes (segmentation faults, compilation errors, and an extraneous `sleep(1)` call), had significant performance issues. A systematic optimization process was undertaken, guided by profiling tools like **TAU, Scalasca, Valgrind, and Perf**.

### Key Optimizations

1.  **MPI Communication:** The most critical bottleneck was the MPI communication pattern. The original code sent a very large number of small, individual messages at each time step, leading to high latency overhead and poor scalability. The solution was to **aggregate data into a single buffer** before sending, drastically reducing the number of MPI calls. Further improvements were made by changing the domain decomposition strategy from horizontal to **vertical partitioning**, which better suited the typical problem geometry and memory layout.

2.  **Hybrid Parallelism (OpenMP):** To leverage shared-memory parallelism within a single compute node, **OpenMP** pragmas (`#pragma omp parallel for`) were added to the most computationally intensive loops (e.g., `collision`, `propagation`). This established a hybrid MPI+OpenMP parallel model.

3.  **Sequential & Cache Performance:** Profiling revealed that inefficient memory access patterns were a significant sequential bottleneck. By **reordering nested loops**, data access was changed to be contiguous in memory, greatly improving cache utilization and the performance of the core computation kernels.

### Results Summary

These optimizations yielded substantial performance improvements and excellent scalability:

*   **Performance Gain:** For the original problem size on a workstation, the time per iteration was reduced from **~11 ms to ~0.12 ms**.
*   **Scalability:** The optimized code demonstrated near-perfect **strong scalability** on multiple architectures. **Weak scalability** was also significantly improved, allowing the simulation to efficiently tackle larger problems.
*   **Bottleneck Analysis:** For very large problem sizes, the simulation transitions from being communication-bound to **memory-bandwidth-bound**. In this regime, the performance limit becomes the speed of RAM access rather than the CPU or network, which is a typical behavior for highly optimized stencil codes like LBM.

This optimization journey highlights classic HPC challenges and demonstrates effective solutions, transforming a slow, unscalable code into a high-performance simulation. 