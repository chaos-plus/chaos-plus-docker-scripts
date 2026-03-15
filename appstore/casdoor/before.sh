#!/bin/bash -e


init_db mysql7 3306 root ${PASSWORD:-} casdoor
init_db mysql8 3306 root ${PASSWORD:-} casdoor