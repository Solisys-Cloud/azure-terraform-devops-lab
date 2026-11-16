# Lab 03 - Exercises

Complete the lab first. Each exercise changes the configuration; always read the plan before applying.

## Exercise 1 (guided): find out which version is really used

**Goal:** check facts instead of trusting the code alone.

1. Open `.terraform/modules/modules.json`.
2. Find the entry with the key `network`.

**Expected:** its `Source` ends with `?ref=v1.0.0` or `?ref=v1.1.0`, matching your `main.tf`.

3. In the module repository, list the published versions:

   ```powershell
   git tag --list
   git show v1.0.0 --stat
   ```

## Exercise 2 (guided): see what an unpinned module would do

**Goal:** understand the risk of a missing `ref`. This exercise only plans; it applies nothing.

1. In `main.tf`, remove `?ref=v1.0.0` from the source.
2. Run `terraform init -upgrade`, then `terraform plan`.

**Expected:** Terraform downloads the latest commit of the default branch. Today the plan may show `No changes`. Tomorrow, after any commit to the module, the same code could plan something different.

3. Restore the `ref` and run `terraform init -upgrade` again.

## Exercise 3 (guided): compare two versions before upgrading

**Goal:** read what changed between two tags, as you would before approving an upgrade.

In the module repository:

```powershell
git diff v1.0.0 v1.1.0 --stat
git diff v1.0.0 v1.1.0 -- variables.tf
```

**Expected:** the new optional attribute appears as added lines. No input was removed or renamed, which confirms a minor version.

## Challenge 1: classify the changes

For each change to the module, decide: major, minor, or patch?

| # | Change |
| --- | --- |
| 1 | Fix a typo in a variable description |
| 2 | Rename the input `virtual_network_name` to `vnet_name` |
| 3 | Add an optional input `dns_servers` with the default `[]` |
| 4 | Rename the resource `azurerm_subnet.this` to `azurerm_subnet.subnet` without a `moved` block |
| 5 | Add a required input `owner` without a default |

<details>
<summary>Show the answers</summary>

| # | Answer | Reason |
| --- | --- | --- |
| 1 | Patch | Nothing changes for callers |
| 2 | Major | Every caller must change its code |
| 3 | Minor | Compatible: existing callers keep working |
| 4 | Major | Terraform would destroy and recreate the subnets of every caller |
| 5 | Major | Existing calls fail with `Missing required argument` |

</details>

## Challenge 2: publish a patch version

The module README has no sentence about cost. Add one line under **Notes** saying that the resources carry no direct charge at the time of writing, then publish the change as `v1.1.1` through a branch and a pull request, update `CHANGELOG.md`, and upgrade this lab.

**Success criteria:**

- The tag `v1.1.1` exists on GitHub and `v1.1.0` still points to its original commit.
- After changing the `ref` and running `terraform init -upgrade`, `terraform plan` shows `No changes`.

<details>
<summary>Show a possible solution</summary>

```powershell
git switch -c docs/add-cost-note
# edit README.md and CHANGELOG.md
git add README.md CHANGELOG.md
git commit -m "Add cost note to the README"
git push -u origin docs/add-cost-note
# merge the pull request on GitHub, then:
git switch main
git pull
git tag -a v1.1.1 -m "Add cost note"
git push origin v1.1.1
```

</details>

## Challenge 3 (advanced): design a major version

Version 2.0.0 should rename the input `virtual_network_name` to `name`. Write, without publishing anything:

1. the changelog entry, with an **Upgrade notes** paragraph for callers;
2. the change a caller must make in its `module` block;
3. the plan a caller should expect after upgrading correctly.

<details>
<summary>Show a possible answer</summary>

1. Changelog: `2.0.0 - Breaking: the input virtual_network_name is renamed to name. Upgrade notes: rename the argument in your module block. No resource is recreated.`
2. Caller change: replace `virtual_network_name = "..."` with `name = "..."` and set `?ref=v2.0.0`.
3. Expected plan: `No changes`. Only the input name changed; the resource and its attributes are the same.

</details>
