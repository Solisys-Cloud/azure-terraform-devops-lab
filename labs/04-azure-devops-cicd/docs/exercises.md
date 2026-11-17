# Lab 04 - Exercises

Complete the lab first. Every exercise goes through a pull request: never push directly to `main`.

## Exercise 1 (guided): read a plan in a pull request

**Goal:** review infrastructure changes before they exist.

1. On a branch, change the `address_space` default in `variables.tf` to `["10.41.0.0/16"]`.
2. Open a pull request.
3. In the pipeline run, open **Initialize, validate and plan**.

**Expected:** the plan replaces the virtual network and its subnets. A reviewer sees this in the pull request, before anything happens. Close the pull request without merging.

## Exercise 2 (guided): break the formatting on purpose

**Goal:** see the pipeline stop early.

1. On a branch, add extra spaces before an argument in `main.tf`.
2. Open a pull request.

**Expected:** **Check formatting** fails and the plan never runs. Run `terraform fmt` locally, push again, and the run turns green.

## Exercise 3 (guided): reject a deployment

**Goal:** prove that the approval is a real gate.

1. Merge a harmless change, for example a new tag value.
2. When the run waits for approval, select **Review**, then **Reject**.

**Expected:** the Apply stage is cancelled and `az resource list --resource-group rg-lab04-network-dev-weu-001` shows no change.

## Challenge 1: protect `main`

On GitHub, add a branch protection rule on `main` that requires the Azure Pipelines check to pass before merging. Then try to merge a pull request with a formatting error.

## Challenge 2: least privilege

Create a second service connection scoped to one existing resource group only, and point the pipeline to it on a branch. What fails in the plan or the apply, and why? (Hint: this code creates its own resource group.) How would you change the design so that the pipeline needs less than Contributor on the whole subscription?

## Challenge 3: a second environment

Add a `lab04-tst` environment and a third stage that deploys the same code with another address space and another state key, after its own approval.
