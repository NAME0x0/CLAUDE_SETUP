---
name: implement-paper
description: Parses research papers/technical documents into implementation plans and code
triggers:
  - /implement-paper
  - /paper-to-code
  - /research-impl
---

# Instructions

When this skill is invoked with a research paper URL, PDF, or arxiv ID, analyze it and create an implementation plan.

## Process

1. **Obtain and Parse Paper**:
   - If arxiv ID: Fetch from `https://arxiv.org/abs/[ID]`
   - If URL: Use WebFetch to retrieve content
   - If PDF path provided: Read the file
   - Extract: Title, Abstract, Key Sections, Algorithms, Equations

2. **Analyze Technical Content**:

   **Identify Core Components**:
   - Main algorithm(s) described
   - Mathematical formulations
   - Data structures required
   - Input/output specifications
   - Hyperparameters and constants

   **Extract Implementation Details**:
   - Pseudocode (if provided)
   - Architecture diagrams
   - Training procedures (for ML papers)
   - Evaluation metrics

3. **Research Dependencies**:
   - Identify required libraries (PyTorch, TensorFlow, NumPy, etc.)
   - Find existing implementations to reference (GitHub, Papers with Code)
   - Note any datasets mentioned

4. **Create PLAN.md**:

   ```markdown
   # Implementation Plan: [Paper Title]

   ## Paper Summary
   [2-3 sentence overview]

   ## Key Contributions
   - [Main contribution 1]
   - [Main contribution 2]

   ## Architecture Overview
   [Mermaid diagram if applicable]

   ## Implementation Steps

   ### Phase 1: Data Structures
   - [ ] Implement [structure 1]
   - [ ] Implement [structure 2]

   ### Phase 2: Core Algorithm
   - [ ] Implement [function 1] - Equation (3)
   - [ ] Implement [function 2] - Algorithm 1

   ### Phase 3: Training/Execution
   - [ ] Implement training loop
   - [ ] Add evaluation metrics

   ## Mathematical Formulations
   [Key equations in LaTeX/code]

   ## Dependencies
   - package1>=version
   - package2>=version

   ## Reference Implementations
   - [Link 1]
   - [Link 2]

   ## Validation Strategy
   [How to verify correctness]
   ```

5. **Generate Starter Code**:
   - Create skeleton classes/functions
   - Add docstrings with paper references
   - Include equation comments for complex math

## Output Format

- Generate PLAN.md with full implementation roadmap
- Create starter code files with structure
- List open questions or ambiguities in the paper
- Suggest simplifications for MVP implementation

## Enhancements

- Search Papers with Code for existing implementations
- Cross-reference citations for prerequisite concepts
- Generate unit tests based on paper's examples
- Create Jupyter notebook for iterative development
- Extract figures/diagrams for reference
- Identify potential optimizations not in paper
