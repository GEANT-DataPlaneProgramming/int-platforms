#!/bin/bash

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Switch 10.0.1.1"

echo "displaying register1"
echo "register_read src_distribution_register1" | docker exec  -i hh simple_switch_CLI --thrift-port 22222
echo
echo "displaying register2"
echo "register_read src_distribution_register2" | docker exec  -i hh simple_switch_CLI --thrift-port 22222
echo
echo "displaying register3"
echo "register_read src_distribution_register3" | docker exec  -i hh simple_switch_CLI --thrift-port 22222
echo
echo "displaying register4"
echo "register_read src_distribution_register4" | docker exec  -i hh simple_switch_CLI --thrift-port 22222
echo

echo
echo "displaying src_distribution list"
echo "register_read src_distribution_r" | docker exec  -i hh simple_switch_CLI --thrift-port 22222
echo

