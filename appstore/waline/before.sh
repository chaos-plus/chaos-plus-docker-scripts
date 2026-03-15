#!/bin/bash -e


init_db mysql7 3306 root ${PASSWORD:-} waline
init_db mysql8 3306 root ${PASSWORD:-} waline
