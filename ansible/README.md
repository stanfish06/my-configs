# ansible

```sh
./run.sh                                  # all hosts in inventory.yml
./run.sh -l oracle-1                      # one host
./run.sh -l greatlakes --skip-tags sudo   # no root: skips the system role
./run.sh -t toolchain,agents              # rerun selected roles
```
