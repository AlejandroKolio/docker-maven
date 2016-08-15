#!/usr/bin/env bats

SUT_IMAGE=bats-maven
SUT_CONTAINER=bats-maven
SUT_TAG=${TAG:-jdk-8}
SUT_TEST_IMAGE=bats-maven-test
SUT_TEST_CONTAINER=bats-maven-test

load test_helpers

@test "$SUT_TAG build image" {
  cd $BATS_TEST_DIRNAME/../$SUT_TAG
  docker build -t $SUT_IMAGE .
}

@test "$SUT_TAG build test image" {
  cd $BATS_TEST_DIRNAME
  docker build -t $SUT_TEST_IMAGE .
}

@test "$SUT_TAG create test container" {
    assert "$(grep 'ARG MAVEN_VERSION' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -e 's/ARG MAVEN_VERSION=//')" \
      bash -c "docker run --rm $SUT_IMAGE mvn -version | grep 'Apache Maven ' | sed -e 's/Apache Maven \([0-9\.]*\) .*/\1/'"
}

@test "$SUT_TAG settings.xml is setup" {
    assert "$(cat $BATS_TEST_DIRNAME/settings.xml)" \
      docker run --rm $SUT_TEST_IMAGE cat /root/.m2/settings.xml
}

@test "$SUT_TAG repository is created" {
    assert "/root/.m2/repository/junit/junit/3.8.1/junit-3.8.1.jar" \
      docker run --rm $SUT_TEST_IMAGE ls /root/.m2/repository/junit/junit/3.8.1/junit-3.8.1.jar
}
