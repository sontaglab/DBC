# Distributed Boolean Computing (DBC) Toolbox 
This repository was created to share the algorithm and database contained in our recent ACS Synthetic Biology paper. 
> **Distributed implementation of Boolean functions by transcriptional synthetic circuits**
> M. Ali Al-Radhawi, Anh Phong Tran, Elizabeth A. Ernst, Tianchi Chen, Christopher A. Voigt, and Eduardo D. Sontag
ACS Synthetic Biology (2020). DOI: 10.1021/acssynbio.0c00228

The code is under MIT license in order to help dissemination of the work. Please cite us if this work came to be helpful.

## Diffusible small molecules (DSM)
Oftentimes, as circuits to be implemented in a given cell becomes too large, toxicity becomes a limiting factor. This translates in practice to cells containing 6-7 gates. Only 11.69% of 4-input Boolean functions are implementable using 7 gates, so one way to alleviate this problem is allowing cells to communicate using DSMs. 

<p align="center">
<img src="images/DSM.png" width="600">
</p>

In our workflow, DSMs can be used to communicate a result from a cell to another cell located "downstream" within a circuit design. Another way is to use the output of multiple cells as an OR gate (essentially if any of the cells produce that DSM, then the output is assumed to be of value 1 regardless of concentration).

## Summary of the framework
In designing Boolean circuits in cell, there are strong biological constraints that need to be accounted for that limits how large of a circuit can one implement in a given cell. In this work, we focus on the idea of distributing the computational burden to multiple cells, while also attempting to use circuits that are optimal in the sense of how many gates are required using a pre-computed database. The main two methods that have been implemented so far are:

- Disjunctive Normal Form (DNF): this algorithm usually yields more compact designs that use less DSMs. This is based around the idea that every Boolean function can be decomposed using a disjunctive normal form and that the final result is essentially a virtual "OR" gate of all these pieces.
- Partitioning: we partition existing circuits that represent the full-fledged logical circuit from an existing database into smaller pieces that communicates using DSMs. We hope to add functions to allow communicating or importing files with other tools.
 
The internal details of how these methodologies operate can be found in the published work.

<p align="center">
<img src="images/design_flowchart.png" width="750">
</p>

## Examples
#### 14 gates implemented using the DNF method using 3 cells and at most 6 gates in a cell (0x977E)

<p align="center">
<img src="images/example_14gates_DNF.png" width="350">
</p>

#### 13 gates using 3 DSMs and the DNF method

<p align="center">
<img src="images/example_13gates_DNF.png" width="600">
</p>

## Use


## Feedback
Feel free to suggest features or provide feedback on possible issues you may encounter using GitHub.