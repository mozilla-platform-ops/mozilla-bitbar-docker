# .bashrc

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
fi

if [ -f /etc/profile ]; then
        . /etc/profile
fi

export ANDROID_HOME=/builds/worker/android-sdk-linux
# old jdk path
# export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# jdk 17 and newer androdi tools path
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# set path to include android tools
export PATH=${PATH}:/usr/local/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/platform-tools/bin:${ANDROID_HOME}/cmdline-tools/latest/bin
# Work around broken libcurl3 minidump_stackwalk requirement.
export LD_LIBRARY_PATH=/builds/worker/LD_LIBRARY

# setup pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Set umask 0 so that a setuid adb will create world readable/writeable
# files while the process is running as the worker user.
umask 0
