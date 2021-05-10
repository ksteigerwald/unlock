
# We pass only the relevent env vars, which are prefixed with the service name, uppercased
# UNLOCK_APP_X will be passed to the container for tests in unlock_app as X.
UPCASE_SERVICE="LOCKSMITH"
TARGET="BEANSTALK"
NODE_ENV="production"

ENV_PREFIX="STAGING_"
DEFAULT_NETWORK="4"
if [ "$ENV_TARGET" = "prod" ]; then
  ENV_PREFIX="PROD_"
  DEFAULT_NETWORK="1"
fi

ENV_VARS_PREFIX="${UPCASE_SERVICE//-/_}_${TARGET^^}_$ENV_PREFIX"
ENVIRONMENT_NAME="$ENV_VARS_PREFIX"ENVIRONMENT
APPLICATION_NAME="$ENV_VARS_PREFIX"APPLICATION


ENV_VARS=`env | grep "^$ENV_VARS_PREFIX" | awk '{print " ",$1}' ORS='' | sed -e "s/$ENV_VARS_PREFIX//g"`


function deploy() {

    eb setenv $ENV_VARS NODE_ENV=$NODE_ENV DEFAULT_NETWORK=$DEFAULT_NETWORK
    if eb status ${!ENVIRONMENT_NAME}; then
        eb deploy ${!ENVIRONMENT_NAME} --label locksmith-${build_id} --message "${message:0:199}" --timeout 10 --verbose
    else
        eb create ${!ENVIRONMENT_NAME} --elb-type classic --debug
    fi
}

cd locksmith

eb init ${!APPLICATION_NAME} -p docker --region us-east-1
deploy ${!ENVIRONMENT_NAME}