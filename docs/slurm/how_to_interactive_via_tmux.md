---
title: "Interactive job inside tmux"
path: blob/master/docs/confs/bin
source: start_interactive
---

Each time you login to Sumner HPC, you will be redirected to one of two login nodes. If you are using ==tmux and running interactive job== (using slurm) on a compute node, you may prefer to detach it, say during lunch or meeting times and like to re-attach afterwards from your local machine. If so, you do need to remember on which of two login nodes your tmux session was running, and login to that node and re-attach tmux session.

This bash wrapper around tmux and slurm scheduler will (for the most part) do that job.

* Using `tmux -V`. I've tested it with v2.9+
* Copy *start_interactive* from [docs/confs/bin](https://github.com/TheJacksonLaboratory/sumnerdocs/blob/master/docs/confs/bin) directory to *~/bin/start_interactive* and `chmod 755 start_interactive`.
    - If needed, change default resources and walltime for interactive job command where variable `INTJOB` is specified.
    - This script will change move `TMUX_TMPDIR` from */tmp* to *~/logs/tmux* and bind tmux session with session ID specific to login-node, e.g., S1 and S2 for respectively, login-node1 and login-node2.
* From your local machine, place a bash wrapper like *~/bin/run_interactive_hpc* with following code, and do `chmod 755 ~/bin/run_interactive_hpc`
    - You may need to add/edit sumner profile in local *~/.ssh/config*.

??? Tip "Local *~/.ssh/config* file"

    ```
    ## example config for sumner.
    Host sumner
        Hostname login.sumner.jax.org
        User foo
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes
        Port 22
        ServerAliveInterval 40
        ServerAliveCountMax 10
        StrictHostKeyChecking no

    Host sumner1
        Hostname sumner-log1.sumner.jax.org
        User foo
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes
        Port 22
        ServerAliveInterval 40
        ServerAliveCountMax 10
        StrictHostKeyChecking no

    Host sumner2
        Hostname sumner-log2.sumner.jax.org
        User foo
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes
        Port 22
        ServerAliveInterval 40
        ServerAliveCountMax 10
        StrictHostKeyChecking no
    ```

```sh
#!/bin/bash

## Run or attach to interactive session on one of sumner login nodes

ssh sumner -t 'bash -l -c "start_interactive"'
exitstat1=$?

if [[ "$exitstat1" != 0 ]]; then
    echo -e "\n#####\nAttempt one more time to match login node and tmux session\n#####\n"
    sleep 5
    ## extract stderr for parsing remote hostname
    ssh sumner -t 'bash -l -c "start_interactive"' >| /tmp/sumner_interactive
    exitstat2=$?

    if [[ "$exitstat2" != 0 ]]; then
        echo -e "\nForce ssh to login node matching tmux session."

        ## get login node where tmux is running
        TMUXHOST="$(grep -Eo "S[12]{1}INT" /tmp/sumner_interactive)"
        echo -e "\ntmux session ID is ${TMUXHOST}\nForce login to server where tmux is running."

        ## Using ~/.ssh/config profile for a specific login node
        if [[ "${TMUXHOST}" == "S1INT" ]]; then
            ssh sumner1 -t 'bash -l -c "start_interactive"'
        elif [[ "${TMUXHOST}" == "S2INT" ]]; then
            ssh sumner2 -t 'bash -l -c "start_interactive"'
        else
            echo -e "\nERROR: Invalid pattern for remote tmux session ID: ${TMUXHOST}\nIt should be either S1INT or S2INT.\nCan not start_interactive session." >&2
            exit 1
        fi
    fi
fi

## END ##
```

*   From your local machine, run `~/bin/run_interactive_hpc` and see if it works! If not, feel free to raise question at [user forum](https://hpctalk.jax.org).

!!! Info "Notes"
    *   Avoid running `start_interactive` while you are on login node or spawning new interactive job inside a custom tmux session. Instead, prefer running `~/bin/run_interactive_hpc` **from your local machine**.
    *   Wrapper allows running only one interactive job with login-node specific job name, and relies on login-node specific tmux session else it will fail to work.
    *   If you like to go back to detached tmux session from login node, you can instead use `tmux new-session -A -s S1` (or S2 for login-node2) to attach to either running session or create a new one. [Details here](https://unix.stackexchange.com/a/176885/28675) or checkout [docs/confs/bin/tmx](https://github.com/TheJacksonLaboratory/sumnerdocs/blob/master/docs/confs/bin/tmx).
