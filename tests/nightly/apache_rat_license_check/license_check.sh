#!/usr/bin/env bash

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


#echo "install maven"
#sudo apt-get install maven -y #>/dev/null

#echo "install svn"
#sudo apt-get install subversion -y #>/dev/null

echo "download RAT"
svn co http://svn.apache.org/repos/asf/creadur/rat/trunk/ #>/dev/null

echo "cd into directory"
cd trunk

echo "mvn install"
mvn -Dmaven.test.skip=true install #>/dev/null

echo "build success, cd into target"
cd apache-rat/target

#chmod -R 777 /home/ubuntu/workspace/NightlyPipeline_onSource/trunk
chmod -R 777 /work/mxnet/trunk/apache-rat-tasks
#rm -y /home/ubuntu/workspace/NightlyPipeline_onSource/trunk/apache-rat-tasks/src/test/resources/antunit/report-normal-operation.xml
#rm -y /home/ubuntu/workspace/NightlyPipeline_onSource/trunk/apache-rat-tasks/src/test/resources/antunit/report-bad-configurations.xml
#rm -y /work/mxnet/trunk/apache-rat-tasks/src/test/resources/antunit/report-normal-operation.xml
rm -y /work/mxnet/trunk/apache-rat-tasks/src/test/resources/antunit/report-normal-operation.xml


echo "run apache RAT check"
java -jar apache-rat-0.13-SNAPSHOT.jar -E /work/mxnet/tests/nightly/apache_rat_license_check/rat-excludes -d /work/mxnet


