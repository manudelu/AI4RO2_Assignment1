Artificial Intelligence for Robotics II
===================================================
AI Planning: Model of a Robotic Coffee Shop Scenario in PDDL 
=============================================================

Project
-------------------

The description of the project can be found [here](https://github.com/manudelu/AI4RO2_Assignment1/blob/4b65f4def3a06bee1da9225ee677f50f3b1c2d07/Assignment1_AI4RO2.pdf).

To gain comprehensive insights into the development process of the project, I highly recommend referring to the report [here](https://github.com/manudelu/AI4RO2_Assignment1/blob/ff5be87272dec13db46c57709abca50988e682d4/Report.pdf).

To access a variety of details regarding the PDDL documentation, I recommend referring to the [Planning Wiki](https://planning.wiki).

LPG
-----------------
LPG, or Local Search for Planning Graphs, is a heuristic search algorithm designed to efficiently solve planning problems. Planning problems involve finding a sequence of actions that can transform an initial state into a desired target state. The planning graph is a representation of the planning problem that captures the dependencies between states and actions.

LPG uses a local search strategy to explore the space of possible solutions. The algorithm starts by generating an initial solution and then iteratively modifies the solution to improve its quality. At each iteration, LPG selects a subset of actions to modify and applies a local search operator to improve the solution. This process continues until a satisfactory solution is found or a predefined stopping criterion is met.

LPG handles PDDL 2.1 domains. The domain syntax in PDDL 2.1 includes two important new features, durative-actions and functions which are referred to as numeric fluents

Running
--------------

For running the planning problems you can type on the terminal the following command:

```bash
./lpg++ -o <operator file name> -f <problem file name> -speed
```

Where `<operator file name>` is the domain file called ”caffe-bar-domain.pddl” and the `<problem file name>` are the problem files called ”problemN.pddl” (with N = 1, 2, 3, 4).

Team Members
-------------

|    |Name |Surname |
|----|---|---|
| 1 | Manuel | Delucchi |
| 2 | Gianluca | Galvagni |
| 3 | Claudio | Demaria |
| 4 | Enrico | Piacenti |
| 5 | Emanuele | Giordano |
