#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.


echo "install maven"
sudo apt install maven -y >/dev/null

echo "install svn"
sudo apt install subversion -y >/dev/null

echo "download RAT"
svn co http://svn.apache.org/repos/asf/creadur/rat/trunk/ >/dev/null

echo "cd into directory"
cd trunk

echo "mvn install"
mvn install >/dev/null

echo "build success, cd into target"
cd apache-rat/target

echo "run apache RAT check"
java -jar apache-rat-0.13-SNAPSHOT.jar -d /home/ubuntu/workspace/Rat_LicenseCheck_2/docs -e ".+\\.xml" -e "\..*" -e ".+\\.css" -e "\\.*" -e ".+\\.ipynb" -e ".+\\.html" -e ".+\\.json" -e ".+\\.js" -e ".+\\.txt" -e ".+\\.md" -e '3rdparty/*' -e '/example/rcnn/rcnn/*' -e 'dmlc-core/*' -e 'mshadow/*' -e 'dmlc-core/*' -e 'dlpack/*' -e 'R-package/*' -e 'nnvm/*' -e 'ps-lite/*' -e 'src/operator/mkl/*' -e 'trunk/*' -e 'docker/*' -e 'docker_multiarch/*' -e ".+\\.m" -e ".+\\.mk" -e ".+\\.R" -e 'contrib/*' -e 'Dockerfile*' -e ".+\\.svg" -e ".+\\.cfg" -e ".+\\.config" -e 'docs/*' -e '__init__.py' -e 'build/*' -e ".+\\.t"

